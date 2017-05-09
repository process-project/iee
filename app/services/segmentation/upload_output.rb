# frozen_string_literal: true

module Segmentation
  class UploadOutput < UploadFile
    include FilestoreUtils

    def initialize(file_path)
      @token = token
      super(Webdav.new(filestore_url, filestore_options), file_path)
    end
  end
end
