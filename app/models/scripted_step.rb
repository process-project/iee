# frozen_string_literal: true

class ScriptedStep < Step
  attr_reader :repository, :file, :deployments

  def initialize(name, repository, file, required_files, options = {})
    super(name, required_files)
    @repository = repository
    @file = file
    @deployments = options.fetch(:deployments, %w[cluster])
  end

  def builder_for(pipeline, params)
    PipelineSteps::Scripted::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Scripted::ScriptedRunner.new(computation, @repository, @file, options)
  end

  def config(force_reload = false)
    {
      tags_and_branches: tags_and_branches(force_reload),
      deployments: @deployments
    }
  end

  private

  def tags_and_branches(force_reload)
    Gitlab::Versions.new(repository, force_reload: force_reload).call
  end
end
