# frozen_string_literal: true
class ServicePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.
        joins(:users).
        where(users: { id: user.id })
    end
  end

  def update?
    owned?
  end

  def destroy?
    owned?
  end

  private

  def owned?
    record.users.include? user
  end
end
