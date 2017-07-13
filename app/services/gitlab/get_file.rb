# frozen_string_literal: true

module Gitlab
  class GetFile
    require 'base64'

    def initialize(project_name, filename, version)
      @project_name = project_name
      @filename = filename
      @version = version
    end

    def call
      Base64.decode64(Gitlab.get_file(@project_name, @filename, @version).content)
    rescue Gitlab::Error::NotFound
      Rails.logger.error("Requested file #{@filename} not found in branch/tag #{@version} "\
      "of project #{@project_name}")
      nil
    rescue SocketError, Gitlab::Error::Parsing
      Rails.logger.error('Unable to establish Gitlab connection. Check your gitlab host config.')
      nil
    end
  end
end
