# frozen_string_literal: true
class ServicePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.
        joins(:users).
        where(users: { id: user.id })
    end
  end

  def show?
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
    [:name, :uri, uri_aliases: []]
  end

  private

  def owned?
    record.users.include? user
  end
end
