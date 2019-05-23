# frozen_string_literal: true

class SingularityStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(
      name,
      required_files = [],
  )
    super(name, required_files)
    @required_files = required_files

    containers_and_tags = SingularityRegistry.fetch_containers name

    # @parameters = [container_name_parameter, container_tag_parameter, hpc_parameter]
    @parameters = build_basic_parameters containers_and_tags
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

  def input_present_for?(pipeline)
    @required_files.map { |rf| pipeline.named_data_file(rf) }.all?
  end

  def add_data_file(df_name)
    @required_files << df_name
  end

  def build_basic_parameters(containers_and_tags)
    container_names = []
    container_tags = []
    container_HPCs = []

    containers_and_tags.each do |container_name, tags|
      container_names << container_name
      tags.each do |container_tag|
        container_tags << container_tag
        SingularityScriptBlueprint.find_by(container_name: container_name,
                                           container_tag: container_tag).each do |blueprint|
          container_HPCs << blueprint.hpc
        end
      end
    end

    container_names_param = StepParameter.new(
      'container_name',
      'Container name',
      'Name of your container',
      0,
      'multi',
      container_names.first,
      container_names.uniq
    )

    container_tags_param = StepParameter.new(
      'container_tag',
      'Container tag',
      'Tag of the container used on registry',
      0,
      'multi',
      container_tags.first,
      container_tags.uniq
    )

    container_HPCs_param = StepParameter.new(
      'container_tag',
      'Container tag',
      'Tag of the container used on registry',
      0,
      'multi',
      container_tags.first,
      container_tags.uniq
    )

    return container_names_param, container_tags_param, container_HPCs_param
  end
end
