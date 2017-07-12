# frozen_string_literal: true

module Gitlab
  class Versions
    def initialize(project_name)
      @project_name = project_name
    end

    def call
      branches = Gitlab.branches(@project_name).collect(&:name)
      tags = Gitlab.tags(@project_name).collect(&:name)

      return { branches: branches, tags: tags }
    rescue Gitlab::Error::MissingCredentials
      Rails.logger.error('Gitlab operation invoked with no valid credentials. '\
      'Make sure  the environment variable GITLAB_API_PRIVATE_TOKEN is defined '\
      'and contains a valid Gitlab private token.')
      { branches: [], tags: [] }
    end
  end
end
