class LobcderComputationPolicy < ApplicationPolicy
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

  def can_update_in_mode?
    if record.manual?
      record.runnable? && !need_proxy?
    else
      record.run_mode.blank?
    end
  end
end