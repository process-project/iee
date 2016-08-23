# frozen_string_literal: true
class User < ApplicationRecord
  include Gravtastic

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

  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :access_policies, dependent: :destroy
  has_many :computations
  has_many :service_ownerships
  has_many :services, through: :service_ownerships

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  scope :approved, -> { where(approved: true) }
  scope :supervisors, -> { joins(:groups).where(groups: { name: 'supervisor' }) }

  def self.with_active_computations
    User.where(<<~SQL
      id IN (SELECT DISTINCT(user_id)
             FROM computations
             WHERE status IN ('queued', 'running'))
    SQL
              )
  end

  def self.from_plgrid_omniauth(auth)
    find_or_initialize_by(plgrid_login: auth.info.nickname).tap do |user|
      set_new_user_attrs(auth, user) if user.new_record?

      user.proxy = User.compose_proxy(auth.info)
      user.save
    end
  end

  def self.set_new_user_attrs(auth, user)
    user.email = auth.info.email
    user.password = Devise.friendly_token.first(8)
    name_elements = auth.info.name.split(' ')
    user.first_name = name_elements[0]
    user.last_name = name_elements[1..-1].join(' ')
    user.approved = true
  end

  def self.from_token(token)
    User.find_by(email: User.token_data(token)[0]['email'])
  end

  def plgrid_connect(auth)
    tap do
      self.plgrid_login = auth.info.nickname
      self.proxy = User.compose_proxy(auth.info)
      save
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
    @admin = groups.where(name: 'admin').exists? if @admin.nil?
    @admin
  end

  def token
    JWT.encode(
      token_payload,
      Vapor::Application.config.jwt.key,
      Vapor::Application.config.jwt.key_algorithm
    )
  end

  # Send devise emails asynchronously.
  # See https://github.com/plataformatec/devise#activejob-integration for
  # details.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def self.token_data(token)
    JWT.decode(token, Vapor::Application.config.jwt.key, true,
               algorithm: Vapor::Application.config.jwt.key_algorithm)
  end

  def self.compose_proxy(info)
    if info.proxy && info.proxyPrivKey && info.userCert
      info.proxy + info.proxyPrivKey + info.userCert
    end
  end

  private

  def token_payload
    {
      name: name,
      email: email,
      iss: Rails.configuration.jwt.issuer,
      exp: Time.now.to_i + Rails.configuration.jwt.expiration_time
    }
  end
end
