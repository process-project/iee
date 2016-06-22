class AccessPolicyPolicy < ApplicationPolicy
  def permitted_attributes
    [:user_id, :group_id, :resource_id, :access_method_id]
  end
end