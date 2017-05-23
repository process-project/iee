# frozen_string_literal: true
module Webdav
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      Webdav::Update.new(user, on_finish_callback: PipelineUpdater).call
    end
  end
end
