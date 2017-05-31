# frozen_string_literal: true
require 'webdav/client'

module Webdav
  class OwnCloud < Webdav::Client
    def initialize
      super(storage_url)
      credentials(Rails.application.config_for('eurvalve')['owncloud']['user'],
                  Rails.application.config_for('eurvalve')['owncloud']['password'])
      self.verify_server = false
    end

    def self.inputs_path
      Rails.application.config_for('eurvalve')['owncloud']['inputs_path']
    end

    def self.outputs_path
      Rails.application.config_for('eurvalve')['owncloud']['outputs_path']
    end

    def self.input_path(computation)
      File.join(inputs_path, computation.working_file_name)
    end

    def self.output_path(computation)
      File.join(outputs_path, computation.working_file_name)
    end

    private

    def storage_url
      Rails.application.config_for('eurvalve')['owncloud']['url']
    end
  end
end
