# frozen_string_literal: true
require 'zip'
require 'fileutils'

module Webdav
  class UploadZipFile
    def initialize(dav_client, local_path, remote_directory)
      @dav_client = dav_client
      @source_zip_path = local_path
      @target_dir = remote_directory
    end

    def call
      Dir.mktmpdir do |tmp_dir|

        Zip::File.open(@source_zip_path) do |zip_file|
          zip_file.each do |file|
            local_path = File.join(tmp_dir, file.name)
            zip_file.extract(file, local_path)

            @dav_client.put_file(local_path, File.join(@target_dir, file.name))
          end
        end

      end
    end
  end
end
