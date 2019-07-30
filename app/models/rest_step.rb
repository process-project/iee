# frozen_string_literal: true

class RestStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(name)
    super(name)
  end

  def builder_for(pipeline, parameter_values)
    PipelineSteps::Rest::Builder.new(
      pipeline,
      name,
      parameter_values,
      @parameters
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::Rest::Runner.new(
      computation,
      options
    )
  end

  def input_present_for?(_pipeline)
    true
  end
end
