module Rimrock
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      Rimrock::Start.new(computation).call
    end
  end
end
