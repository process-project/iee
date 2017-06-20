# frozen_string_literal: true
require 'zip'
require 'fileutils'

module Webdav
  class UploadZipFile
    def initialize(dav_client, local_path, remote_directory)
      @dav_client = dav_client
      @local_path = local_path
      @remote_directory = remote_directory
    end

    def call
      # Spawn temporary directory to store extracted files
      Dir.mktmpdir do |tmp_dir|

        Zip::File.open(@local_path) do |zip_file|
          zip_file.each do |file|
            tmp_local_path = File.join(tmp_dir, file.name)
            zip_file.extract(file, tmp_local_path)

            # Construct remote path for this file
            @dav_client.put_file(tmp_local_path, File.join(@remote_directory, file.name))
          end
        end

      end
    end
  end
end
