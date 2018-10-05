# frozen_string_literal: true

class UserAgentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      if user&.admin? || user&.supervisor?
        scope.all
      else
        scope.where(user_id: user&.id)
      end
    end
  end

  def index?
    supervisor? || owned?
  end

  def show?
    supervisor? || owned?
  end

  private

  def supervisor?
    user&.admin? || user&.supervisor?
  end

  def owned?
    record.user == user
  end
end
