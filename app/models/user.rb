class User < ActiveRecord::Base
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

  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :permissions, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  
  scope :approved, -> { where(approved: true) }

  def self.from_plgrid_omniauth(auth)
    find_or_initialize_by(plgrid_login: auth.info.nickname).tap do |user|
      if user.new_record?
        user.email = auth.info.email
        user.password = Devise.friendly_token.first(8)
        name_elements = auth.info.name.split(' ')
        user.first_name = name_elements[0]
        user.last_name = name_elements[1..-1].join(' ')
        user.save
      end
    end
  end

  def plgrid_connect(auth)
    tap { update_attribute(:plgrid_login, auth.info.nickname) }
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  def owns_resource?(resource)
    resource.permissions.where(user_id: id).exists?
  end
end
