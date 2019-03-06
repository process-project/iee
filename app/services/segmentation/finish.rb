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
        call { |f| without_repetition(f) }
    end

    def without_repetition(file_name)
      no_repetition_name = file_name.sub(/#{repetition}\.{0,1}/, '')
      File.extname(no_repetition_name).empty? ? file_name : no_repetition_name
    end

    def repetition
      @repetition ||= compute_repetition
    end

    def compute_repetition
      repetition = File.basename(@computation.working_file_name,
                                 File.extname(@computation.working_file_name))
      repetition[1] == '_' ? repetition[2..-1] : repetition
    end

    def update_computation(attrs)
      @computation.update(attrs)
      @updater.new(@computation).call
    end
  end
end
