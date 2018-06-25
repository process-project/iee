# frozen_string_literal: true

module Segmentation
  class Finish
    def initialize(computation, updater, options = {})
      @computation = computation
      @updater = updater
      @segmentation = options.fetch(:segmentation) { Webdav::Segmentation.new }
      @file_store = options.fetch(:file_store) do
        Webdav::FileStore.new(computation.user)
      end
    end

    def call
      download_output
      save_output
      update_computation(status: 'finished')
    rescue StandardError => e
      Rails.logger.error(e)
      update_computation(status: 'error', error_message: e.message)
    end

    private

    def download_output
      @local_file_path = download_service.call
    end

    def download_service
      Webdav::DownloadFile.new(@segmentation,
                               Webdav::Segmentation.output_path(@computation))
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

    def update_computation(attrs)
      @computation.update_attributes(attrs)
      @updater.new(@computation).call
    end
  end
end
