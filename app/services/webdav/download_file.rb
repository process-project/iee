# frozen_string_literal: true

module Webdav
  class DownloadFile
    def initialize(dav_client, remote_path)
      @dav_client = dav_client
      @remote_path = remote_path
    end

    def call
      file_name = File.basename(@remote_path)
      file_name = yield(file_name) if block_given?
      local_file_path = File.join(Dir.mktmpdir, file_name)

      @dav_client.get_file(@remote_path, local_file_path)
      local_file_path
    end
  end
end
