# frozen_string_literal: true
class ServicePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.
          joins(:users).
          where(users: { id: user.id })
      end
    end
  end

  def show?
    user.admin? || owned?
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
    [:name, :uri, user_ids: [], uri_aliases: []]
  end

  private

  def owned?
    record.users.include? user
  end
end
