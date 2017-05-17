# frozen_string_literal: true

module Segmentation
  class UploadInput < UploadFile
    include OwncloudUtils

    def initialize(file_path)
      super(WebdavClient.new(owncloud_url, owncloud_options), file_path)
      @remote_path = Rails.application.config_for('eurvalve')['owncloud']['inputs_path']
    end

    private

    def build_remote_file_name
      separator = @remote_path.end_with?('/') ? '' : '/'
      @remote_path + separator + strip_local_filename(@file_path)
    end
  end
end
