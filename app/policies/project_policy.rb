# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      # NOTE Here insert the code that decides what Projects the current_user
      # is able to see.
      scope
    end
  end

  def index?
    true
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

  def destroy?
    true
  end

  def permitted_attributes
    [:project_name]
  end
end
