# frozen_string_literal: true

class SingularityScriptGenerator
  def initialize(computation)
    @computation = computation
  end

  def call
    record = matching_blueprint
    fill_values = computation_parameter_values

    filled_script = record.script_blueprint % fill_values
  end

  private

  # rubocop:disable Metrics/AbcSize
  def computation_parameter_values
    fill_values = {}
    fill_values[:container_name] = @computation.container_name
    fill_values[:container_tag] = @computation.container_tag
    compute_site_name = @computation.compute_site.name
    fill_values[:compute_site_name] = compute_site_name
    fill_values[:uc_root] = Lobcder::Service.new(@computation.uc).
                            site_root(compute_site_name.to_sym)
    fill_values[:pipeline_hash] = @computation.pipeline.name # TODO: paths should belong to pipeline

    temp = @computation.parameter_values&.symbolize_keys
    fill_values = fill_values.merge(temp) unless temp.nil?

    fill_values
  end
  # rubocop:enable Metrics/AbcSize

  def matching_blueprint
    SingularityScriptBlueprint.find_by!(
      container_name: @computation.container_name,
      container_tag: @computation.container_tag,
      compute_site: @computation.compute_site
    )
  end
end
