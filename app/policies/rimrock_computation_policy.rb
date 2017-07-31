# frozen_string_literal: true

class RimrockComputationPolicy < ApplicationPolicy
  def permitted_attributes
    [:revision]
  end
end
