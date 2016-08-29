# frozen_string_literal: true
class Resource < ApplicationRecord
  enum resource_type: [:global, :local]

  has_many :access_policies, dependent: :destroy
  belongs_to :service

  validates :path, presence: true, uniqueness: { scope: :service_id }
  validates :service, presence: true
  validates :resource_type, presence: true
  validate :local_path_exclusion

  before_validation :unify_path

  def self.normalize_path(path)
    if path && path.starts_with?('/')
      path[1..-1]
    else
      path
    end
  end

  def self.paths_exist?(paths)
    Resource.where(path: paths).count == paths.length
  end

  def self.normalize_paths(paths)
    paths.map { |path| normalize_path(path) }
  end

  def uri
    uri = URI.parse(service.uri)
    uri.path = "/#{path}"

    uri.to_s
  end

  private

  def unify_path
    self.path = Resource.normalize_path(path)
  end

  def local_path_exclusion
    if Resource.where(resource_type: :local).where('path ~ :path', path: path).exists?
      errors.add(:resource_type, 'local resource paths cannot overlap')
    end
  end
end
