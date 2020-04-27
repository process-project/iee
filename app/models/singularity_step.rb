# frozen_string_literal: true

class SingularityStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(
      name,
      required_files = []
  )
    super(name, required_files)
    @required_files = required_files
    @parameters = ParameterFetcher.new(name, SingularityRegistry).call
  end

  def builder_for(pipeline, parameter_values)
    PipelineSteps::Singularity::Builder.new(
      pipeline,
      name,
      parameter_values,
      @parameters
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::Singularity::Runner.new(
      computation,
      options
    )
  end
end
