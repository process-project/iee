# frozen_string_literal: true

class ScriptedStep < Step
  attr_reader :repo, :file

  def initialize(name, repository, file, required_files = [])
    super(name, required_files)

    @repository = repository
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Scripted::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    case computation.deployment
    when 'cluster'
      PipelineSteps::Scripted::RimrockRunner.new(computation, @repository, @file, options)
    when 'cloud'
      PipelineSteps::Scripted::CloudRunner.new(computation, @repository, @file, options)
    end
  end
end
