# frozen_string_literal: true

class ParameterFetcher
  def initialize(step_name, registry)
    @step_name = step_name
    @registry = registry
  end

  def call
    containers_and_tags = @registry.fetch_containers @step_name
    possibilities = get_basic_parameters_possibilities containers_and_tags

    basic_parameters(possibilities) + specific_parameters(possibilities)
  end

  private

  def basic_parameters(possibilities)
    build_basic_parameters possibilities
  end

  def specific_parameters(possibilities)
    fetch_specific_parameters possibilities
  end

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
