# frozen_string_literal: true

class CloudifyComputationPolicy < ApplicationPolicy
  def permitted_attributes
    [:tag_or_branch, :service_name]
  end

  def show?
    true
  end

  def update?
    record.user == user && !record.active? &&
      can_update_in_mode?
  end

  def need_proxy?
    false
  end

  private

  def can_update_in_mode?
    record.runnable? && !need_proxy?
  end
end
