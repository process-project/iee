# frozen_string_literal: true

class RestStep < Step
  attr_reader :parameters

  def initialize(name, parameters = [])
    super(name)
    @parameters = parameters
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
end
