# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      if user&.admin? || user&.supervisor?
        scope.all
      else
        scope.where(id: user&.id)
      end
    end
  end

  def index?
    supervisor?
  end

  def destroy?
    user&.admin?
  end

  def update?
    supervisor?
  end

  def manage_users?
    supervisor?
  end

  private

  def supervisor?
    user&.admin? || user&.supervisor?
  end
end
