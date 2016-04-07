class PermissionPolicy < ApplicationPolicy
  def permitted_attributes
    [:user_id, :group_id, :resource_id, :action_id]
  end
end