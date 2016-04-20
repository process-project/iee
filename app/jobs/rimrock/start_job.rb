module Rimrock
  class StartJob < ActiveJob::Base
    queue_as :computation

    def perform(computation)
      Rimrock::Start.new(computation).call
    end
  end
end
