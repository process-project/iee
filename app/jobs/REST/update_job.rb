# frozen_string_literal: true

module REST
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      REST::Update.new(computation,
                            on_finish_callback: PipelineUpdater,
                            updater: ComputationUpdater).call
    end
  end
end
