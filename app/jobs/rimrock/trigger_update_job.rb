# frozen_string_literal: true
module Rimrock
  class TriggerUpdateJob < ApplicationJob
    queue_as :computation

    def perform
      User.with_submitted_computations.each do |user|
        Rimrock::UpdateJob.perform_later(user)
      end
    end
  end
end
