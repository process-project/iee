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
    owned?
  end

  def update?
    owned?
  end

  def destroy?
    owned?
  end

  def permitted_attributes
    [:name, :default, member_ids: [], owner_ids: [], child_ids: []]
  end

  private

  def owned?
    UserGroup.where(group_id: record.id, user_id: user.id, owner: true).exists?
  end
end