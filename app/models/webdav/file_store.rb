# frozen_string_literal: true

module Webdav
  class FileStore < Webdav::Client
    class << self
      def url
        config['web_dav_base_url']
      end

      def path
        config['web_dav_base_path']
      end

      def proxy_path
        config['web_dav_policy_proxy_path']
      end

      private

      def config
        Rails.configuration.constants['file_store']
      end
    end

    def initialize(user)
      super(storage_url,
            headers: { 'Authorization' => "Bearer #{user.try(:token)}" })
    end

    private

    def storage_url
      File.join(Webdav::FileStore.url, Webdav::FileStore.path, '/')
    end
  end
end
