# frozen_string_literal: true

class User < ApplicationRecord
  include Gravtastic
  include CheckExistenceConcern

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :omniauthable,
         omniauth_providers: [:open_id]

  gravtastic default: 'mm'

  enum state: [:new_account, :approved, :blocked]

  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :access_policies, dependent: :destroy
  has_many :resource_managers, dependent: :destroy
  has_many :computations, dependent: :nullify
  has_many :service_ownerships, dependent: :destroy
  has_many :services, through: :service_ownerships

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  scope :approved, -> { where(state: :approved) }
  scope :new_accounts, -> { where(state: :new_account) }
  scope :blocked, -> { where(state: :blocked) }
  scope :supervisors, -> { joins(:groups).where(groups: { name: 'supervisor' }) }

  def self.with_submitted_computations(computation_type)
    condition = <<~SQL
      id IN (SELECT DISTINCT(user_id) FROM computations
              WHERE type = ? AND status IN ('queued', 'running'))
    SQL
    User.where(condition, computation_type)
  end

  def self.from_plgrid_omniauth(auth)
    find_or_initialize_by(plgrid_login: auth.info.nickname).tap do |user|
      set_new_user_attrs(auth, user) if user.new_record?

      user.proxy = User.compose_proxy(auth.info)
      user.proxy_expired_notification_time = nil
    end
  end

  def self.set_new_user_attrs(auth, user)
    user.email = auth.info.email
    user.password = Devise.friendly_token.first(8)
    name_elements = auth.info.name.split(' ')
    user.first_name = name_elements[0]
    user.last_name = name_elements[1..-1].join(' ')
    user.state = :approved
  end

  def self.from_token(token)
    User.find_by(email: JwtToken.decode(token)[0]['email'])
  end

  def self.compose_proxy(info)
    return unless info.proxy && info.proxyPrivKey && info.userCert

    info.proxy + info.proxyPrivKey + info.userCert
  end

  def plgrid_connect(auth)
    tap do
      self.plgrid_login = auth.info.nickname
      self.proxy = User.compose_proxy(auth.info)
      self.proxy_expired_notification_time = nil
    end
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end

  def name
    "#{first_name} #{last_name}"
  end

  def admin?
    @admin ||= groups.where(name: 'admin').exists?
  end

  def supervisor?
    @supervisor ||= groups.where(name: 'supervisor').exists?
  end

  def token(expiration_time_in_seconds = nil)
    JwtToken.new(self).generate(expiration_time_in_seconds)
  end

  # Send devise emails asynchronously.
  # See https://github.com/plataformatec/devise#activejob-integration for
  # details.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def all_groups
    groups.includes(:parents).flat_map { |group| [group] + group.ancestors }
  end

  def all_group_names
    all_groups.map(&:name)
  end
end
