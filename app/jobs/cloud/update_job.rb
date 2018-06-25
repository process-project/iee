# frozen_string_literal: true

module Cloud
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      Cloud::Update.new(user,
                        on_finish_callback: PipelineUpdater,
                        updater: ComputationUpdater).call
    end
  end
end
