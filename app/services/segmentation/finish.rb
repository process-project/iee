# frozen_string_literal: true
module Segmentation
  class Finish
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
      @local_file_path = download_service.call
    end

    def download_service
      Webdav::DownloadFile.new(Webdav::OwnCloud.new,
                               Webdav::OwnCloud.output_path(@computation))
    end

    def save_output
      Webdav::UploadZipFile.new(Webdav::FileStore.new(@computation.user),
                                @local_file_path, File.dirname(@computation.output_path)).call
    end

    def update_pipeline
      @computation.update_attributes(status: 'finished')
      @updater.new(@computation).call
    end
  end
end
