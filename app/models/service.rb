# frozen_string_literal: true
class Service < ApplicationRecord
  has_many :resources, dependent: :destroy
  has_many :service_ownerships, dependent: :destroy
  has_many :users, through: :service_ownerships

  validates :uri,
            presence: true,
            uniqueness: true,
            format: { with: /\A#{URI.regexp}\z/ }
  validates :users,
            presence: true

  before_validation :check_if_not_override_uri
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
end
