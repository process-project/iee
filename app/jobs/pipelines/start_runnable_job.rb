# frozen_string_literal: true

module Pipelines
  class StartRunnableJob < ApplicationJob
    queue_as :computation

    def perform(pipeline)
      Pipelines::StartRunnable.new(pipeline).call
    end
  end
end
