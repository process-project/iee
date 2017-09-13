# frozen_string_literal: true

module Segmentation
  class Finish
    def initialize(computation, updater, options = {})
      @computation = computation
      @updater = updater
      @own_cloud = options.fetch(:own_cloud) { Webdav::OwnCloud.new }
      @file_store = options.fetch(:file_store) do
        Webdav::FileStore.new(computation.user)
      end
    end

    def call
      download_output
      save_output
    rescue => e
      Rails.logger.error(e)
      update_pipeline 'error', e
    else
      update_pipeline 'finished'
    end

    private

    def download_output
      @local_file_path = download_service.call
    end

    def download_service
      Webdav::DownloadFile.new(@own_cloud,
                               Webdav::OwnCloud.output_path(@computation))
    end

    def save_output
      Webdav::UploadZipFile.
        new(@file_store,
            @local_file_path,
            @computation.output_path).
        call { |f| without_prefix(f) }
    end

    def without_prefix(file_name)
      prefixless = file_name.gsub(/^#{prefix}\.{0,1}/, '')
      File.extname(prefixless).empty? ? file_name : prefixless
    end

    def prefix
      @prefix ||= File.basename(@computation.working_file_name,
                                File.extname(@computation.working_file_name))
    end

    def update_pipeline(st, e = nil)
      @computation.update_attributes(status: st)
      @computation.update_attributes(error_message: e) unless e.nil?
      @updater.new(@computation).call
    end
  end
end
