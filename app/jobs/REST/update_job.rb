# frozen_string_literal: true

module Rest
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      Rest::Update.new(user,
                       on_finish_callback: PipelineUpdater,
                       updater: ComputationUpdater).call
    end
  end
end
