# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class CloudifyStep < Step
  attr_reader :parameters

  def initialize(
      name,
      required_files = []
  )
    super(name, required_files)

    @required_files = required_files

    # containers_and_tags = SingularityRegistry.fetch_containers name
    # possibilities = get_basic_parameters_possibilities containers_and_tags

    # basic_parameters = build_basic_parameters possibilities
    # specific_parameters = fetch_specific_parameters possibilities

    @parameters = []
  end

  def builder_for(pipeline, parameter_values)
    PipelineSteps::Cloudify::Builder.new(
      pipeline,
      name,
      parameter_values
    )
  end

  def runner_for(computation, options = {})
    PipelineSteps::Cloudify::Runner.new(
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

  private

  # rubocop:disable Metrics/MethodLength
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

    {
      container_names: container_names,
      container_tags: container_tags,
      HPCs: hpcs
    }
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

    container_hpcs_param = StepParameter.new(
      label: 'hpc',
      name: 'HPC',
      description: 'High Performance Computer',
      rank: 0,
      datatype: 'multi',
      default: possibilities[:HPCs].first,
      values: possibilities[:HPCs]
    )

    [container_names_param, container_tags_param, container_hpcs_param]
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
            merge_parameter_into(specific_parameters, specific_parameter)
          end
        end
      end
    end

    specific_parameters
  end
  # rubocop:enable Metrics/MethodLength

  def merge_parameter_into(specific_parameters, sp_new)
    if specific_parameters.include? sp_new
      specific_parameters.each do |sp_old|
        if sp_old == sp_new
          sp_old.values |= sp_new.values
          break
        end
      end
    else
      specific_parameters << sp_new
    end
  end
end
# rubocop:enable Metrics/ClassLength
