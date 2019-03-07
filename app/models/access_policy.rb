# frozen_string_literal: true

class AccessPolicy < ApplicationRecord
  include UserOrGroupConcern

  belongs_to :access_method
  belongs_to :resource

  validates :access_method,
            inclusion: {
              in: ->(ap) { ap.resource&.service&.access_methods },
              unless: ->(ap) { ap.access_method&.service.nil? },
              message: I18n.t('different_service_access_method')
            }
  validates :user_id, uniqueness: {
    scope: [:group_id, :access_method_id, :resource_id],
    message: I18n.t('activerecord.errors.models.access_policy.attributes.user.uniqueness')
  }
end
