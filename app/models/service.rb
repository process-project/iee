# frozen_string_literal: true
class Service < ApplicationRecord
  has_many :resources, dependent: :destroy
  has_many :access_methods, dependent: :destroy
  has_many :service_ownerships, dependent: :destroy
  has_many :users, through: :service_ownerships

  validates :uri,
            presence: true,
            uniqueness: true,
            format: { with: /\A#{URI.regexp}\z/ }
  validates :users,
            presence: true
  validate :uri_does_not_end_with_slash

  before_validation :reject_blank_aliases
  before_validation :check_if_not_override_uri
  before_validation :check_if_not_overridden_by_uri

  before_validation :check_uri_aliases_format
  before_validation :check_uri_aliases_uniqueness
  before_validation :check_uri_aliases_same
  before_validation :check_if_not_overridden_by_alias
  before_validation :check_if_alias_not_overridden

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

  def uri_does_not_end_with_slash
    errors.add(:uri, 'Service URI cannot end with a slash') if uri.present? && uri.end_with?('/')
  end

  def reject_blank_aliases
    uri_aliases.reject!(&:blank?)
  end

  def check_override(uri)
    return false unless uri.present?
    sc = Service.where('uri LIKE ?', "#{uri}%").where.not(id: id)

    # Regexp used to eliminate false-positives for TLDs (e.g. .co vs .com)
    sc.any? { |s| (s.uri =~ %r{\A.*:\/\/.*\/.*\z}) }
  end

  def check_if_not_override_uri
    if check_override(uri)
      errors.add(:uri, I18n.t('activerecord.errors.models.service.uri.override'))
    end
  end

  def check_if_not_overridden_by_uri
    return false unless uri.present?

    if Service.where.not(id: id).any? { |s| uri.start_with? "#{s.uri}/" }
      errors.add(:uri, I18n.t('activerecord.errors.models.service.uri.overridden'))
    end
  end

  def check_overridden(op1, op2)
    op1.any? { |a| a == op2 || a.start_with?("#{op2}/") || op2.start_with?("#{a}/") }
  end

  def check_if_not_overridden_by_alias
    return false unless uri.present?

    if Service.where.not(id: id).any? { |s| check_overridden(uri_aliases, s.uri) }
      errors.add(:uri_aliases,
                 I18n.t('activerecord.errors.models.service.uri_aliases.overridden'))
    end
  end

  def check_if_alias_not_overridden
    return false unless uri.present?

    if Service.where.not(id: id).any? { |s| check_overridden(s.uri_aliases, uri) }
      errors.add(:uri_aliases,
                 I18n.t('activerecord.errors.models.service.uri_aliases.overridden'))
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

  def check_uri_aliases_format
    if uri_aliases.any? { |u| !(u =~ /\A#{URI.regexp}\z/) }
      errors.add(:uri_aliases, I18n.t('activerecord.errors.models.service.uri_aliases.format'))
    end
  end

  def check_uri_aliases_same
    if uri_aliases.any? { |u| u == uri }
      errors.add(:uri_aliases,
                 I18n.t('activerecord.errors.models.service.uri_aliases.urialiassame'))
    end
  end

  # Checks if any of the aliases overlaps with any of the services' aliases
  def check_uri_aliases_uniqueness
    if uri_aliases.any? { |u| duplicate_aliases?(u) }
      errors.add(:uri_aliases, I18n.t('activerecord.errors.models.service.uri_aliases.uniqueness'))
    end
  end
end
