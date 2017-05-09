# frozen_string_literal: true

module Segmentation
  class DownloadInput < DownloadFile
    include FilestoreUtils

    def initialize(input_remote_path, token)
      @token = token
      super(Webdav.new(filestore_url, filestore_options), remote_path(input_remote_path))
    end

    private

    def remote_path(input_remote_path)
      filestore_base_path + '/' + input_remote_path
    end
  end
end
