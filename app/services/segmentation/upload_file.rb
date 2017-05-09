# frozen_string_literal: true

module Segmentation
  class UploadFile < FileService
    def call
      @dav_client.put_file(@file_path, build_remote_file_name)
    end

    private

    def initialize(dav_client, file_path)
      super(dav_client)
      @file_path = file_path
    end

    def strip_local_filename
      @file_path.gsub(%r{.*\/}, '')
    end
  end
end
