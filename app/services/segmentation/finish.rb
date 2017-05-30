# frozen_string_literal: true

module Segmentation
  class Finish
    include Segmentation::OwncloudUtils
    def initialize(computation, updater)
      @computation = computation
      @updater = updater
    end

    def call
      download_output
      save_output
      update_pipeline
    end

    private

    def download_output
      remote_path = output_path @computation
      download = DownloadOutput.new(remote_path)
      @local_file_path = download.call
    end

    def save_output
      upload = UploadOutput.new(
        @local_file_path,
        @computation.output_path,
        @computation.user.token
      )
      upload.call
    end

    def update_pipeline
      @computation.update_attributes(status: 'finished')
      @updater.new(@computation).call
    end
  end
end
