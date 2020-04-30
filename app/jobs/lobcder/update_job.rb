# frozen_string_literal: true

module Lobcder
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      Lobcder::Update.new(computation,
                          on_finish_callback: PipelineUpdater,
                          updater: ComputationUpdater).call
    end
  end
end
