# frozen_string_literal: true

module Segmentation
  class UploadOutput < UploadFile
    include FilestoreUtils

    def initialize(file_path, remote_output_path, token)
      @token = token
      @remote_output_path = File.join(filestore_base_path, remote_output_path)

      super(WebdavClient.new(filestore_url, filestore_options), file_path)
    end

    private

    def build_remote_file_name
      @remote_output_path
    end
  end
end
