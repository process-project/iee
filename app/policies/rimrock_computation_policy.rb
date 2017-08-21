# frozen_string_literal: true

class RimrockComputationPolicy < ApplicationPolicy
  def permitted_attributes
    [:tag_or_branch]
  end
end
