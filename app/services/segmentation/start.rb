# frozen_string_literal: true

module Segmentation
  class Start
    include FileUtils
    def initialize(computation)
      @computation = computation
      @download_input = DownloadInput.new(computation.input_path, computation.user.token)
    end

    def call
      download_input
      update_computation
      upload_input
    end

    private

    def download_input
      @local_path = @download_input.call
    end

    def update_computation
      @computation.update_attributes(working_file_name: strip_local_filename(@local_path))
    end

    def upload_input
      UploadInput.new(@local_path).call
    end
  end
end
