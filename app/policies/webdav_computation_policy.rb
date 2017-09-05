# frozen_string_literal: true

class WebdavComputationPolicy < ApplicationPolicy
  def permitted_attributes
    []
  end

  def show?
    true
  end

  def update?
    record.manual? && record.runnable?
  end

  def need_proxy?
    false
  end
end
