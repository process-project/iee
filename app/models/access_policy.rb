# frozen_string_literal: true

class AccessPolicy < ApplicationRecord
  include UserOrGroupConcern

  belongs_to :access_method
  belongs_to :resource

  validates :access_method_id,
            presence: { message: I18n.t('missing_access_method') },
            inclusion: {
              in: ->(ap) { ap.resource&.service&.access_methods&.map(&:id) },
              unless: ->(ap) { ap.access_method&.service.nil? },
              message: I18n.t('different_service_access_method')
            }
  validates :resource_id, presence: { message: I18n.t('missing_resource') }
  validates :user_id, uniqueness: {
    scope: [:group_id, :access_method_id, :resource_id],
    message: I18n.t('similar_access_policy_exists')
  }
end
