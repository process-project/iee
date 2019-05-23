# frozen_string_literal: true

require 'erb'

class SingularityScriptGenerator
  attr_reader :computation

  def initialize(computation)
    @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))

    @computation = computation
  end

  def call
    record = SingularityScriptBlueprint.find_by!(container_name: computation.container_name,
                                                 container_tag: computation.container_tag,
                                                 hpc: computation.hpc)

    fill_values = computation.parameter_values.symbolize_keys
    fill_values[:container_name] = computation.container_name
    fill_values[:container_tag] = computation.container_tag
    fill_values[:hpc] = computation.hpc

    @staging_logger.debug("fill_values: #{fill_values}")

    parameters_filled_script = record.script_blueprint % fill_values

    ScriptGenerator.new(@computation, parameters_filled_script).call
  end
end
