# frozen_string_literal: true

module Gitlab
  class Versions
    def initialize(project_name, force_reload: false, gitlab_client: Gitlab)
      @project_name = project_name
      @force_reload = force_reload
      @gitlab_client = gitlab_client
    end

    def call
      Rails.cache.fetch("gitlab-versions/#{@project_name}",
                        force: @force_reload) { fetch }
    end

    private

    def fetch
      branches = @gitlab_client.branches(@project_name).collect(&:name)
      tags = @gitlab_client.tags(@project_name).collect(&:name)
      return { branches: branches, tags: tags }
    rescue Gitlab::Error::MissingCredentials
      Rails.logger.error('Gitlab operation invoked with no valid credentials. '\
      'Make sure the environment variable GITLAB_API_PRIVATE_TOKEN is defined ')
      { branches: [], tags: [] }
    rescue SocketError, Gitlab::Error::Parsing
      Rails.logger.error('Unable to establish Gitlab connection. Check your gitlab host config.')
      { branches: [], tags: [] }
    end
  end
end
