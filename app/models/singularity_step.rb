# frozen_string_literal: true

class SingularityStep < Step
  attr_reader :repository, :file

  def initialize(name, registry_url, container_name, container_tag, required_files = [])
    super(name, required_files)
    @registry_url = registry_url
    @container_name = container_name
    @container_tag = container_tag
  end

  def builder_for(pipeline, _params)
    PipelineSteps::Singularity::Builder.new(
      pipeline,
      name,
      @registry_url,
      @container_name,
      @container_tag
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::Singularity::Runner.new(
      computation,
      @registry_url,
      @container_name,
      @container_tag,
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
