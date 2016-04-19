module Rimrock
  class TriggerUpdateJob < ActiveJob::Base
    queue_as :computation

    def perform()
      User.with_active_computations.each do |user|
        Rimrock::UpdateJob.perform_later(user)
      end
    end
  end
end
