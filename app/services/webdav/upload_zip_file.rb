# frozen_string_literal: true

require 'zip'

module Webdav
  class UploadZipFile
    def initialize(dav_client, source_zip_path, target_dir)
      @dav_client = dav_client
      @source_zip_path = source_zip_path
      @target_dir = target_dir
    end

    def call
      Zip::File.open(@source_zip_path) do |zip_file|
        zip_file.each do |file|
          file_name = block_given? ? yield(file.name) : file.name
          @dav_client.put(File.join(@target_dir, file_name),
                          file.get_input_stream, file.size)
        end
      end
    end
  end
end
