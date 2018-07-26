# frozen_string_literal: true

class RimrockStep < Step
  attr_reader :repository, :file

  def initialize(name, repository, file, required_files = [])
    super(name, required_files)
    @repository = repository
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Scripted::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Scripted::ScriptedRunner.new(computation, @repository, @file, options)
  end
end
