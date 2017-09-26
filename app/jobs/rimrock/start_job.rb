# frozen_string_literal: true

module Rimrock
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      GuardedProxyExecutor.new(computation.user).call do
        Rimrock::Start.new(computation).call
        ComputationUpdater.new(computation).call
      end
    end
  end
end
