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
      can_update_in_mode?
  end

  def need_proxy?
    !(record.finished? || Proxy.new(user)&.valid?)
  end

  private

  def can_update_in_mode?
    if record.manual?
      record.runnable? && !need_proxy?
    else
      record.tag_or_branch.blank?
    end
  end
end
