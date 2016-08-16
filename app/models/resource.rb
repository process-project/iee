# frozen_string_literal: true
class Resource < ApplicationRecord
  enum resource_type: [:global, :local]
  
  has_many :access_policies, dependent: :destroy
  belongs_to :service

  validates :path, presence: true, uniqueness: { scope: :service_id }
  validates :service, presence: true

  before_validation :unify_path

  def uri
    uri = URI.parse(service.uri)
    uri.path = "/#{path}"

    uri.to_s
  end

  def self.normalize_path(path)
    if path && path.starts_with?('/')
      path[1..-1]
    else
      path
    end
  end

  private

  def unify_path
    self.path = Resource.normalize_path(path)
  end
end
