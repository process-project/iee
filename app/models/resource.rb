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
  validate :pretty_path_asterisk_at_the_end

  after_validation :copy_path_errors

  scope :local_paths,
        lambda { |path|
          where(resource_type: :local).where('path ~* CONCAT(\'^\', CONCAT(:path, \'$\'))',
                                             path: path)
        }

  def uri
    uri = URI.parse(service.uri)
    uri.path += pretty_path

    uri.to_s
  end

  def pretty_path
    if path
      PathService.to_pretty_path(path)
    else
      path
    end
  end

  def pretty_path=(pretty_path)
    self.path = PathService.to_path(pretty_path)
  end

  private

  def local_path_exclusion
    return unless Resource.local_paths(path).where(service: service).exists?
    errors.add(:path, 'local resource paths cannot overlap')
  end

  def path_starts_with_slash
    return unless path.present? && !path.start_with?('/')
    errors.add(:path, 'Resource path must start with a slash')
  end

  def pretty_path_asterisk_at_the_end
    if pretty_path && pretty_path.include?('*') &&
       (pretty_path.match(/\*$/).nil? || pretty_path.count('*') > 1)
      errors.add(:pretty_path, I18n.t('activerecord.errors.models.resource.pretty_path.wildcard'))
    end
  end

  def copy_path_errors
    errors.add(:pretty_path, errors[:path][0]) if errors.include?(:path)
  end
end
