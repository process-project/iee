# frozen_string_literal: true

module Segmentation
  module OwncloudUtils
    private

    def owncloud_url
      Rails.application.config_for('eurvalve')['owncloud']['url']
    end

    def owncloud_options
      {
        verify_server: false,
        username: Rails.application.config_for('eurvalve')['owncloud']['user'],
        password: Rails.application.config_for('eurvalve')['owncloud']['password']
      }
    end
  end
end
