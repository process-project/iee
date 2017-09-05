# frozen_string_literal: true

class PipelinePolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end

  def show?
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

  def permitted_attributes_for_create
    [:name, :flow, :mode]
  end

  def permitted_attributes_for_update
    [:name]
  end

  private

  def owned?
    record.user == user
  end
end
