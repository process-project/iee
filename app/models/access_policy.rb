class AccessPolicy < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :access_method
  belongs_to :resource

  validate :user_xor_group

  validates :access_method_id, presence: { message: I18n.t("missing_access_method") }
  validates :resource_id, presence: { message: I18n.t("missing_resource") }
  validates :user_id, uniqueness: {
    scope: [:group_id, :access_method_id, :resource_id],
    message: I18n.t("similar_access_policy_exists")
  }

  def user_xor_group
    if !(user_id.nil? ^ group_id.nil?)
      errors.add(:user_id, I18n.t("either_user_or_group"))
      errors.add(:group_id, I18n.t("either_user_or_group"))
    end
  end
end
