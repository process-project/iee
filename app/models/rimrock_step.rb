# frozen_string_literal: true

class RimrockStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(name, repository, file, required_files = [], parameters = [])
    super(name, required_files)

    @repository = repository
    @file = file
    @parameters = parameters
  end

  def builder_for(pipeline, params)

    Rails.logger.debug("+++RimrockStep.builder_for with params: #{params.inspect}")

    PipelineSteps::Rimrock::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Rimrock::Runner.new(computation, @repository, @file, options)
  end
end
