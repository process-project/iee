# frozen_string_literal: true
class ServicePolicy < ApplicationPolicy
  def update?
    record.users.include? user
  end
end
