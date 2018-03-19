# frozen_string_literal: true

class UserAuditPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end

  def index?
    user.admin? || owned?
  end

  def show?
    user.admin? || owned?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  private

  def owned?
    record.user == user
  end
end
