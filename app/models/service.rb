# frozen_string_literal: true
class Service < ApplicationRecord
  has_many :resources, dependent: :destroy
  has_many :service_ownerships
  has_many :users, through: :service_ownerships

  validates :uri,
            presence: true,
            uniqueness: true,
            format: { with: /\A#{URI.regexp}\z/ }

  before_validation :check_if_not_override_uri
  before_validation :check_uri_alias
  before_validation :check_uri_aliases_format
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

  def check_if_not_override_uri
    if uri.present? && Service.where('uri LIKE ?', "#{uri}%").where.not(id: id).count.positive?
      errors.add(:uri,
                 I18n.t('activerecord.errors.models.service.uri.override'))
    end
  end

  def check_uri_alias
    if uri.present? && Service.where('exists (select * from (select unnest(services.uri_aliases)) '\
                                     'x(uri_aliases) where x.uri_aliases like ?)',
                                     "#{uri}%").where.not(id: id).count.positive?
      errors.add(:uri,
                 I18n.t('activerecord.errors.models.service.uri.override'))
    end
  end

  def check_uri_aliases_format
    uri_aliases.each do |uri_alias|
      next if uri_alias =~ /\A#{URI.regexp}\z/
      errors.add(:uri_alias,
                 I18n.t('activerecord.errors.models.service.uri_alias.format'))
      break
    end
  end

  def check_uri_aliases_same(u_alias)
    if u_alias == uri
      errors.add(:uri_alias,
                 I18n.t('activerecord.errors.models.service.uri_alias.urialiassame'))
      return false
    end
    true
  end

  def check_uri_aliases_overlap(u_alias)
    unless Service.where('uri LIKE ?', "#{u_alias}%").where.not(id: id).empty?
      errors.add(:uri,
                 I18n.t('activerecord.errors.models.service.uri.override'))
      return false
    end
    true
  end

  def check_uri_aliases_uniqueness
    uri_aliases.each do |uri_alias|
      break unless check_uri_aliases_same(uri_alias)
      break unless check_uri_aliases_overlap(uri_alias)
      next if Service.where('exists (select * from (select unnest(services.uri_aliases)) '\
                            'x(uri_aliases) where x.uri_aliases like ?)',
                            "#{uri_alias}%").where.not(id: id).empty?
      # next if Service.where('? LIKE ANY (uri_aliases)', uri_alias).where.not(id: id).empty?
      errors.add(:uri_alias,
                 I18n.t('activerecord.errors.models.service.uri_alias.uniqueness'))
      break
    end
  end
end
