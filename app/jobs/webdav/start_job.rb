# frozen_string_literal: true

module Webdav
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      Segmentation::Start.new(computation).call
      computation.update_attributes(status: 'running')
    rescue StandardError => e
      Rails.logger.error(e)
      computation.update_attributes(status: 'error',
                                    error_message: e.message)
    end
  end
end
