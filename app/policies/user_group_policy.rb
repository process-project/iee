# frozen_string_literal: true

class UserGroupPolicy < ApplicationPolicy
  def destroy?
    group_owner?
  end

  def permitted_attributes
    [:owner, user_id: []]
  end

  private

  def group_owner?
    user.admin? || GroupPolicy.new(user, record.group).update?
  end
end
