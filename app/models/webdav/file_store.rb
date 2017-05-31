# frozen_string_literal: true
require 'webdav/client'

module Webdav
  class FileStore < Webdav::Client
    def initialize(user)
      super(storage_url,
            headers: { 'Authorization' => "Bearer #{user.try(:token)}" })
    end

    private

    def storage_url
      File.join(Rails.configuration.constants['file_store']['web_dav_base_url'],
                Rails.configuration.constants['file_store']['web_dav_base_path'],
                '/')
    end
  end
end
