# frozen_string_literal: true

module Segmentation
  class DownloadFile < FileService
    def call
      local_file_path = generate_unique_local_file_path
      @dav_client.get_file(@remote_path, local_file_path)
      local_file_path
    end

    private

    def initialize(dav_client, remote_path)
      super(dav_client)
      @remote_path = remote_path
    end

    def generate_unique_local_file_path
      "#{Dir.mktmpdir}/0_#{SecureRandom.uuid}_#{strip_local_filename(@remote_path)}"
    end
  end
end
