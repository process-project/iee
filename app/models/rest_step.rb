# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class RESTStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(name)
    super(name)
  end

  def builder_for(pipeline, parameter_values)
    PipelineSteps::REST::Builder.new(
      pipeline,
      name,
      parameter_values,
      @parameters
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::REST::Runner.new(
      computation,
      options
    )
  end

  def input_present_for?(pipeline)
    true
  end

  private


end
# rubocop:enable Metrics/ClassLength