# frozen_string_literal: true

class SingularityStep < Step
  attr_reader :repository, :file, :parameters

  def initialize(
      name,
      required_files = []
  )
    super(name, required_files)
    @required_files = required_files

    containers_and_tags = SingularityRegistry.fetch_containers name
    possibilities = get_basic_parameters_possibilities containers_and_tags

    basic_parameters = build_basic_parameters possibilities
    specific_parameters = fetch_specific_parameters possibilities

    @parameters = basic_parameters + specific_parameters
  end

  def builder_for(pipeline, params)
    PipelineSteps::Singularity::Builder.new(
      pipeline,
      name,
      params,
      @parameters
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::Singularity::Runner.new(
      computation,
      options)
  end

  def input_present_for?(pipeline)
    @required_files.map { |rf| pipeline.named_data_file(rf) }.all?
  end

  def add_data_file(df_name)
    @required_files << df_name
  end

  def get_basic_parameters_possibilities(containers_and_tags)
    container_names = []
    container_tags = []
    hpcs = []

    containers_and_tags.each do |container_name, tags|
      container_names |= [container_name]
      tags.each do |container_tag|
        container_tags |= [container_tag]
        matching_blueprints = SingularityScriptBlueprint.where(container_name: container_name,
                                                               container_tag: container_tag)
        matching_blueprints.each do |blueprint|
          hpcs |= [blueprint.hpc]
        end
      end
    end

    return {container_names: container_names,
            container_tags: container_tags,
            HPCs: hpcs}
  end

  def build_basic_parameters(possibilities)
    container_names_param = StepParameter.new(
      label: 'container_name',
      name: 'Container name',
      description: 'Name of your container',
      rank: 0,
      datatype: 'multi',
      default: possibilities[:container_names].first,
      values: possibilities[:container_names]
    )

    container_tags_param = StepParameter.new(
      label: 'container_tag',
      name: 'Container tag',
      description: 'Tag of the container used on registry',
      rank: 0,
      datatype: 'multi',
      default: possibilities[:container_tags].first,
      values: possibilities[:container_tags]
    )

    container_HPCs_param = StepParameter.new(
      label: 'hpc',
      name: 'HPC',
      description: 'High Performance Computer',
      rank: 0,
      datatype: 'multi',
      default: possibilities[:HPCs].first,
      values: possibilities[:HPCs]
    )

    return [container_names_param, container_tags_param, container_HPCs_param]
  end

  def fetch_specific_parameters(possibilities)
    container_names = possibilities[:container_names]
    container_tags = possibilities[:container_tags]
    hpcs = possibilities[:HPCs]

    specific_parameters = []
    container_names.each do |container_name|
      container_tags.each do |container_tag|
        hpcs.each do |hpc|
          blueprint = SingularityScriptBlueprint.find_by(container_name: container_name,
                                                         container_tag: container_tag,
                                                         hpc: hpc)
          next if blueprint.nil?

          blueprint.step_parameters.each do |specific_parameter|
            specific_parameters |= [specific_parameter]
          end
        end
      end
    end

    return specific_parameters
  end
end
