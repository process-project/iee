class Resource < ActiveRecord::Base
  has_many :access_policies, dependent: :destroy
  belongs_to :service

  validates :path, presence: true, uniqueness: { scope: :service_id }

  before_validation :unify_path

  def uri
    uri = URI.parse(service.uri)
    uri.path = "/#{path}"

    uri.to_s
  end

  private

  def unify_path
    self.path = path[1..-1] if path && path.starts_with?('/')
  end
end
