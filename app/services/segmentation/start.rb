# frozen_string_literal: true

module Segmentation
  class Start
    def initialize(computation)
      @computation = computation
    end

    def call
      download_input
      update_computation
      upload_input
      cleanup

      @computation.update_attributes(status: 'running')
    end

    private

    def download_input
      @local_path = download_service.
                    call { |f| "#{mode}_#{SecureRandom.uuid}_#{f}" }
    end

    def download_service
      Webdav::DownloadFile.new(Webdav::FileStore.new(@computation.user),
                               @computation.input_path)
    end

    def mode
      Rails.application.config_for('eurvalve')['seg_service']['mode']
    end

    def update_computation
      @computation.
        update_attributes(working_file_name: File.basename(@local_path),
                          stdout_path: status_dir_path)
    end

    def upload_input
      Webdav::UploadFile.new(Webdav::Segmentation.new, @local_path,
                             Webdav::Segmentation.input_path(@computation)).call
    end

    def status_dir_path
      "#{segmentation['ui_url']}?dir=/status/#{local_path_dir_name}"
    end

    def local_path_dir_name
      File.basename(@local_path, File.extname(@local_path))
    end

    def segmentation
      @segmentation ||= Rails.application.config_for('eurvalve')['seg_service']
    end

    def cleanup
      File.delete(@local_path) if File.exist?(@local_path)
    end
  end
end
