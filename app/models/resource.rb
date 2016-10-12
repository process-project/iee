# frozen_string_literal: true
class Resource < ApplicationRecord
  include CheckExistenceConcern

  enum resource_type: [:global, :local]

  has_many :access_policies, dependent: :destroy
  belongs_to :service

  validates :path, presence: true, uniqueness: { scope: :service_id }
  validates :service, presence: true
  validates :resource_type, presence: true
  validate :local_path_exclusion, if: :local?
  validate :path_starts_with_slash

  def uri
    uri = URI.parse(service.uri)
    uri.path += path

    uri.to_s
  end

  def local_path_exclusion
    if Resource.where(resource_type: :local).where('path ~ :path', path: path).exists?
      errors.add(:path, 'local resource paths cannot overlap')
    end
  end

  private

  def path_starts_with_slash
    if path.present? && !path.start_with?('/')
      errors.add(:path, 'Resource path must start with a slash')
    end
  end
end
