# frozen_string_literal: true
module Webdav
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      Segmentation::Start.new(computation).call
      computation.update_attributes(status: 'running')
    rescue
      computation.update_attributes(status: 'error')
      raise $ERROR_INFO
    end
  end
end
