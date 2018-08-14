# frozen_string_literal: true

module Webdav
  class Segmentation < Webdav::Client
    def initialize
      super(storage_url)
      credentials(Rails.application.config_for('process')['segmentation']['user'],
                  Rails.application.config_for('process')['segmentation']['password'])
      self.verify_server = false
    end

    class << self
      def input_path(computation, prefix = '')
        File.join(inputs_path, "#{prefix}#{computation.working_file_name}")
      end

      def output_path(computation)
        File.join(outputs_path, computation.working_file_name)
      end

      private

      def inputs_path
        Rails.application.config_for('process')['segmentation']['inputs_path']
      end

      def outputs_path
        Rails.application.config_for('process')['segmentation']['outputs_path']
      end
    end

    private

    def storage_url
      Rails.application.config_for('process')['segmentation']['url']
    end
  end
end
