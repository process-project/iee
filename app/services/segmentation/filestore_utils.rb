# frozen_string_literal: true

module Segmentation
  module FilestoreUtils
    private

    def filestore_url
      Rails.application.config_for('application')['file_store']['web_dav_base_url']
    end

    def filestore_base_path
      Rails.application.config_for('application')['file_store']['web_dav_base_path']
    end

    def filestore_options
      { headers: { 'Authorization' => "Bearer #{@token}" } }
    end
  end
end
