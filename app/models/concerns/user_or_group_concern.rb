# frozen_string_literal: true
module UserOrGroupConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :user, optional: true
    belongs_to :group, optional: true

    validate :user_xor_group_present
  end

  def user_xor_group_present
    return if user_id.nil? ^ group_id.nil?
    errors.add(:user_id, I18n.t('either_user_or_group'))
    errors.add(:group_id, I18n.t('either_user_or_group'))
  end
end
