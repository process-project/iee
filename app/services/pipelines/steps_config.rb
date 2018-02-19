# frozen_string_literal: true

module Pipelines
  class StepsConfig
    def initialize(flow, force_reload: false)
      @steps = Flow.steps(flow)&.map(&:name)
      @force_reload = force_reload
    end

    def call
      Hash[@steps.map { |step| [step, config(step)] }]
    end

    private

    def config(step)
      # Can be extended by other step types
      { tags_and_branches: tags_and_branches(step) }
    end

    def tags_and_branches(step)
      repo = repo(step)
      Gitlab::Versions.new(repo, force_reload: @force_reload).call if repo
    end

    def repo(step)
      Rails.application.config_for('eurvalve')['git_repos'][step]
    end
  end
end
