# frozen_string_literal: true

module Cloudify
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      Cloudify::Update.new(user,
                           on_finish_callback: PipelineUpdater,
                           updater: ComputationUpdater).call
    end
  end
end
