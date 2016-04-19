module Rimrock
  class UpdateJob < ActiveJob::Base
    queue_as :computation

    def perform(user)
      Rimrock::Update.new(user).call
    end
  end
end
