class Audits::PerformJob < ApplicationJob
  queue_as :audits

  def perform(user)
    Audits::Perform.new(user).call
  end
end
