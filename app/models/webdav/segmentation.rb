# frozen_string_literal: true

module Webdav
  class Segmentation < Webdav::Client
    def initialize
      super(storage_url)
      credentials(Rails.application.config_for('eurvalve')['segmentation']['user'],
                  Rails.application.config_for('eurvalve')['segmentation']['password'])
      self.verify_server = false
    end

    class << self
      def input_path(computation)
        File.join(inputs_path, computation.working_file_name)
      end

      def output_path(computation)
        File.join(outputs_path, computation.working_file_name)
      end

      private

      def inputs_path
        Rails.application.config_for('eurvalve')['segmentation']['inputs_path']
      end

      def outputs_path
        Rails.application.config_for('eurvalve')['segmentation']['outputs_path']
      end
    end

    private

    def storage_url
      Rails.application.config_for('eurvalve')['segmentation']['url']
    end
  end
end
