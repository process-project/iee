# frozen_string_literal: true

module Api
  class FilesController < Api::ApplicationController
    skip_before_action :authenticate_user!
    before_action :ensure_file_store!

    def create
      DataFiles::CreateJob.perform_later(paths)
      head :created
    end

    def destroy
      DataFiles::DestroyJob.perform_later(paths)
      head :ok
    end

    private

    def ensure_file_store!
      invalid! unless valid_token?
    end

    def valid_token?
      ENV['FILESTORE_SECRET'] && ENV['FILESTORE_SECRET'] == token
    end

    def token
      request.headers['HTTP_X_FILESTORE_TOKEN']
    end

    def invalid!
      head :unauthorized,
           'WWW-Authenticate' => 'X-FILESTORE-TOKEN header is invalid'
    end

    def paths
      return [] unless params[:paths]

      paths_tab.map { |p| Addressable::URI.unescape(p) }
    end

    def paths_tab
      params[:paths].is_a?(String) ? params[:paths].split(',') : params[:paths]
    end
  end
end
