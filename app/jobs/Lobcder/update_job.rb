# frozen_string_literal: true

module StagingIn
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      StagingIn::Update.new(computation,
                            on_finish_callback: PipelineUpdater,
                            updater: ComputationUpdater).call
    end
  end
end
