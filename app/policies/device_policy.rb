# frozen_string_literal: true

class DevicePolicy < ApplicationPolicy
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

  private

  def supervisor?
    user&.admin? || user&.supervisor?
  end
end