# frozen_string_literal: true

class SingularityScriptGenerator
  def initialize(computation)
    @computation = computation
  end

  def call
    record = matching_blueprint
    fill_values = computation_parameter_values

    filled_script = record.script_blueprint % fill_values

    # Neede for now, we sometimes use functionality of the old ScriptGenerator in our scripts
    # e.g for staging in/out to/from webdav
    ScriptGenerator.new(@computation, filled_script).call
  end

  private

  def computation_parameter_values
    fill_values = {}
    fill_values[:container_name] = @computation.container_name
    fill_values[:container_tag] = @computation.container_tag
    fill_values[:compute_site_name] = @computation.compute_site.name

    temp = @computation.parameter_values&.symbolize_keys
    fill_values = fill_values.merge(temp) unless temp.nil?

    fill_values
  end

  def matching_blueprint
    SingularityScriptBlueprint.find_by!(
      container_name: @computation.container_name,
      container_tag: @computation.container_tag,
      compute_site: @computation.compute_site
    )
  end
end
