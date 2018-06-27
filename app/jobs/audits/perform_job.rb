# frozen_string_literal: true

module Audits
  class PerformJob < ApplicationJob
    queue_as :audits

    def perform(user)
      Audits::Perform.new(user).call
    end
  end
end
