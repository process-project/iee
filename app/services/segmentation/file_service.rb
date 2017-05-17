# frozen_string_literal: true

module Segmentation
  class FileService
    include Segmentation::FileUtils

    private

    def initialize(dav_client)
      @dav_client = dav_client
    end
  end
end
