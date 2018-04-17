# frozen_string_literal: true

class ScriptedStep < Step
  attr_reader :repo, :file

  def initialize(name, repository, file, required_files = [], deployment = 'cluster')
    super(name, required_files)

    @repository = repository
    @file = file
    @deployment = deployment
  end

  def builder_for(pipeline, params)
    PipelineSteps::Scripted::Builder.new(pipeline, name, @deployment, params)
  end

  def runner_for(computation, options = {})
    case @deployment
    when 'cluster'
      PipelineSteps::Scripted::RimrockRunner.new(computation, @repository, @file, options)
    when 'cloud'
      PipelineSteps::Scripted::CloudRunner.new(computation, @repository, @file, options)
    end
  end
end
