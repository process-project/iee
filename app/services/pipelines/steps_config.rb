# frozen_string_literal: true

module Pipelines
  class StepsConfig
    def initialize(flow, force_reload: false)
      @steps = Flow.steps(flow)
      @force_reload = force_reload
    end

    def call
      Hash[@steps.map { |step| [step.name, config(step)] }]
    end

    private

    def config(step)
      # Can be extended by other step types
      {
        tags_and_branches: tags_and_branches(step),
        deployment: %w[cluster cloud],
        run_modes: run_modes(step)
      }
    end

    def tags_and_branches(step)
      repo = step.try(:repository)
      Gitlab::Versions.new(repo, force_reload: @force_reload).call if repo
    end

    def repo(step)
      Rails.application.config_for('eurvalve')['git_repos'][step.name]
    end

    def run_modes(step)
      step.try(:run_modes)
    end
  end
end
