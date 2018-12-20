# frozen_string_literal: true

class SingularityComputationPolicy < ApplicationPolicy
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
end
