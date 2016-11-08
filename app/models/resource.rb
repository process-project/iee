# frozen_string_literal: true
class Resource < ApplicationRecord
  include CheckExistenceConcern

  enum resource_type: [:global, :local]

  has_many :access_policies, dependent: :destroy
  has_many :resource_managers, dependent: :destroy
  belongs_to :service

  validates :path, presence: true, uniqueness: { scope: :service_id }
  validates :service, presence: true
  validates :resource_type, presence: true
  validate :local_path_exclusion, if: :local?
  validate :path_starts_with_slash

  scope :local_paths,
        ->(path) { where(resource_type: :local).where('path ~ :path', path: path) }

  def uri
    uri = URI.parse(service.uri)
    uri.path += path

    uri.to_s
  end

  private

  def local_path_exclusion
    return unless Resource.local_paths(path).exists?
    errors.add(:path, 'local resource paths cannot overlap')
  end

  def path_starts_with_slash
    return unless path.present? && !path.start_with?('/')
    errors.add(:path, 'Resource path must start with a slash')
  end
end
