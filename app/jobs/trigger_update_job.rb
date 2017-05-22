# frozen_string_literal: true

class TriggerUpdateJob < ApplicationJob
  queue_as :computation

  def perform
    User.with_submitted_computations.each do |user|
      Rimrock::UpdateJob.perform_later(user)
    end
  end
end
