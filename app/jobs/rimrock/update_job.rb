# frozen_string_literal: true

module Rimrock
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      GuardedProxyExecutor.new(user).call do
        Rimrock::Update.new(user,
                            on_finish_callback: PipelineUpdater,
                            updater: ComputationUpdater).call
      end
    end
  end
end
