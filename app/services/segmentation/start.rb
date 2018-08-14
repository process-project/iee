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
                    call { |f| "#{run_mode}_#{SecureRandom.uuid}_#{f}" }
    end

    def download_service
      Webdav::DownloadFile.new(Webdav::FileStore.new(@computation.user),
                               @computation.input_path)
    end

    def run_mode
      @computation.run_mode
    end

    def update_computation
      @computation.
        update_attributes(working_file_name: File.basename(@local_path),
                          stdout_path: status_dir_path)
    end

    def upload_input
      Webdav::UploadFile.new(client, @local_path, input_path_with_prefix).call
      Webdav::MoveFile.new(client, input_path_with_prefix, input_path).call
    end

    def client
      @client ||= Webdav::Segmentation.new
    end

    def input_path
      Webdav::Segmentation.input_path(@computation)
    end

    def input_path_with_prefix
      Webdav::Segmentation.input_path(@computation, 'tmp-')
    end

    def status_dir_path
      # TODO: reintegrate stdout_path (requires FileStore support)
      # "#{segmentation['ui_url']}?dir=/status/#{local_path_dir_name}"

      nil
    end

    def local_path_dir_name
      File.basename(@local_path, File.extname(@local_path))
    end

    def segmentation
      @segmentation ||= Rails.application.config_for('process')['segmentation']
    end

    def cleanup
      File.delete(@local_path) if File.exist?(@local_path)
    end
  end
end
