class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :action
  belongs_to :resource
  
  validate :user_xor_group, :action_required, :resource_required, :similar
  
  def user_xor_group
    if !(user_id.nil? ^ group_id.nil?)
      errors.add(:user_id, I18n.t("either_user_or_group"))
      errors.add(:group_id, I18n.t("either_user_or_group"))
    end
  end

  #using standard presence validator did not work (validates :action, presence: { message: I18n.t("missing_action") })  
  def action_required
    if action_id.nil?
      errors.add(:action_id, I18n.t("missing_action"))
    end
  end
  
  def resource_required
    if resource_id.nil?
      errors.add(:resource_id, I18n.t("missing_resource"))
    end
  end
  
  def similar
    if similar_exists?
      errors.add(:base, I18n.t("similar_permission_exists"))
    end
  end
  
  def similar_exists?
    !Permission.find_by(user_id: user_id, group_id: group_id, action_id: action_id,
        resource_id: resource_id).nil?
  end
end