# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope
    end
  end

  def show?
    true
  end

  def new?
    true
  end

  def create?
    true
  end

  def edit?
    user.admin? || owned?
  end

  def update?
    user.admin? || owned?
  end

  def destroy?
    user.admin? || owned?
  end

  def permitted_attributes
    [:name, :default, child_ids: []]
  end

  private

  def owned?
    UserGroup.where(group_id: record.id, user_id: user.id, owner: true).exists?
  end
end
