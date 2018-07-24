# frozen_string_literal: true

class WebdavComputationPolicy < ApplicationPolicy
  def permitted_attributes
    [:run_mode]
  end

  def show?
    true
  end

  def update?
    record.user == user && !record.active? && can_update_in_mode?
  end

  def need_proxy?
    false
  end

  private

  def can_update_in_mode?
    if record.manual?
      record.runnable?
    else
      record.run_mode.blank?
    end
  end
end
