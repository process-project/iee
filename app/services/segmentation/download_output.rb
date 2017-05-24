# frozen_string_literal: true

module Segmentation
  class DownloadOutput < DownloadFile
    include OwncloudUtils

    def initialize(output_remote_path)
      @remote_path = output_remote_path
      super(WebdavClient.new(owncloud_url, owncloud_options), output_remote_path)
    end
  end
end
