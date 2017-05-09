# frozen_string_literal: true
module Webdav
  class StartJob < ApplicationJob
    queue_as :computation

    def perform(computation)
      Segmentation::Start.new(computation).call
    end
  end
end
