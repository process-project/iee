# frozen_string_literal: true

class ResourceManagerPolicy < ApplicationPolicy
  def permitted_attributes
    [:user_id, :group_id, :resource_id]
  end

  def destroy?
    true
  end
end
