# frozen_string_literal: true

module Segmentation
  class Start
    def initialize(computation)
      @computation = computation
    end

    def call
      download_input
      update_computation
      upload_input
    end

    private

    def download_input
      @local_path = download_service.call { |f| "0_#{SecureRandom.uuid}_#{f}" }
    end

    def download_service
      Webdav::DownloadFile.new(Webdav::FileStore.new(@computation.user),
                               @computation.input_path)
    end

    def update_computation
      @computation.update_attributes(working_file_name: File.basename(@local_path))
    end

    def upload_input
      Webdav::UploadFile.new(Webdav::OwnCloud.new, @local_path,
                             Webdav::OwnCloud.input_path(@computation)).call
    end
  end
end
