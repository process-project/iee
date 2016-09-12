# frozen_string_literal: true
class Service < ApplicationRecord
  has_many :resources, dependent: :destroy
  has_many :service_ownerships
  has_many :users, through: :service_ownerships

  validates :uri,
            presence: true,
            uniqueness: true,
            format: { with: /\A#{URI.regexp}\z/ }

  before_validation :reject_blank_aliases
  before_validation :check_if_not_override_uri
  before_validation :check_uri_alias
  before_validation :check_uri_aliases_format
  before_validation :check_uri_aliases_overlap
  before_validation :check_uri_aliases_same
  before_validation :check_uri_aliases_uniqueness
  before_create :generate_token

  def to_s
    uri
  end

  private

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.hex
      break random_token unless Service.exists?(token: random_token)
    end
  end

  def reject_blank_aliases
    uri_aliases.reject!(&:blank?)
  end

  def check_if_not_override_uri
    if uri.present? && Service.where('uri LIKE ?', "#{uri}%").where.not(id: id).count.positive?
      errors.add(:uri,
                 I18n.t('activerecord.errors.models.service.uri.override'))
    end
  end

  def duplicate_aliases?(la)
    sql = <<~SQL
      EXISTS (SELECT * FROM (SELECT unnest(services.uri_aliases))
       x(uri_aliases) WHERE x.uri_aliases LIKE ?)
    SQL
    Service.where(sql, "#{la}%").where.not(id: id).count.positive?
  end

  def duplicate_uri?(u)
    Service.where('uri LIKE ?', "#{u}%").where.not(id: id).count.positive?
  end

  def check_uri_alias
    if uri.present? && duplicate_aliases?(uri)
      errors.add(:uri,
                 I18n.t('activerecord.errors.models.service.uri.override'))
    end
  end

  def check_uri_aliases_format
    if uri_aliases.any? { |u| !(u =~ /\A#{URI.regexp}\z/) }
      errors.add(:uri_aliases,
                 I18n.t('activerecord.errors.models.service.uri_aliases.format'))
    end
  end

  # Checks if any of the aliases is the same as uri itself
  def check_uri_aliases_same
    if uri_aliases.any? { |u| u == uri }
      errors.add(:uri_aliases,
                 I18n.t('activerecord.errors.models.service.uri_aliases.urialiassame'))
    end
  end

  # Checks if any of the aliases overlaps with other services' uri
  def check_uri_aliases_overlap
    if uri_aliases.any? { |u| duplicate_uri?(u) }
      errors.add(:uri,
                 I18n.t('activerecord.errors.models.service.uri.override'))
    end
  end

  # Checks if any of the aliases overlaps with any of the services' aliases
  def check_uri_aliases_uniqueness
    if uri_aliases.any? { |u| duplicate_aliases?(u) }
      errors.add(:uri_aliases,
                 I18n.t('activerecord.errors.models.service.uri_aliases.uniqueness'))
    end
  end
end
