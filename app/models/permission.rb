class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :action
  belongs_to :resource

  validate :user_xor_group

  validates :action_id, presence: { message: I18n.t("missing_action") }
  validates :resource_id, presence: { message: I18n.t("missing_resource") }
  validates :user_id, uniqueness: {
    scope: [:group_id, :action_id, :resource_id],
    message: I18n.t("similar_permission_exists")
  }

  def user_xor_group
    if !(user_id.nil? ^ group_id.nil?)
      errors.add(:user_id, I18n.t("either_user_or_group"))
      errors.add(:group_id, I18n.t("either_user_or_group"))
    end
  end
end
