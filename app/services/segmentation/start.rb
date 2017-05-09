# frozen_string_literal: true

module Segmentation
  class Start
    def initialize(computation)
      @download_input = DownloadInput.new(computation.input_path, computation.user.token)
    end

    def call
      local_path = @download_input.call
      UploadInput.new(local_path).call
    end
  end
end
