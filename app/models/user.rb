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

  def self.from_token(token)
    User.find_by(email: User.token_data(token)[0]['email'])
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

  def token
    JWT.encode({ name: name, email: email },
               Vapor::Application.config.jwt.key,
               Vapor::Application.config.jwt.key_algorithm)
  end

  private

  def self.token_data(token)
    JWT.decode(token, Vapor::Application.config.jwt.key, true,
               algorithm: Vapor::Application.config.jwt.key_algorithm)
  end
end
