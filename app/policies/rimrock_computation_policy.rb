# frozen_string_literal: true

class RimrockComputationPolicy < ApplicationPolicy
  def permitted_attributes
    [:tag_or_branch]
  end

  def show?
    true
  end

  def update?
    record.user == user && !record.active? &&
      (record.manual? ? record.runnable? : record.tag_or_branch.blank?)
  end

  def need_proxy?
    !(record.finished? || Proxy.new(user)&.valid?)
  end
end
