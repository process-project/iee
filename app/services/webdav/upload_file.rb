# frozen_string_literal: true

module Webdav
  class UploadFile
    def initialize(dav_client, local_path, remote_path)
      @dav_client = dav_client
      @local_path = local_path
      @remote_path = remote_path
    end

    def call
      @dav_client.put_file(@local_path, @remote_path)
    end
  end
end
