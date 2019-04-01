# frozen_string_literal: true

class SingularityStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(
      name,
      required_files = [],
      parameters = []
  )
    super(name, required_files)
    @required_files = required_files
    @parameters = parameters
  end

  def builder_for(pipeline, params)
    @user_parameters = params
    PipelineSteps::Singularity::Builder.new(
      pipeline,
      name,
      @user_parameters,
      @parameters
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::Singularity::Runner.new(
      computation,
      @user_parameters,
      options
    )
  end

  def input_present_for?(pipeline)
    @required_files.map { |rf| pipeline.named_data_file(rf) }.all?
  end

  def add_data_file(df_name)
    @required_files << df_name
  end
end
