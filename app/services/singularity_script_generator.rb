# frozen_string_literal: true

require 'erb'

class SingularityScriptGenerator
  attr_reader :computation

  def initialize(computation)
    @computation = computation
  end

  def call
    record = SingularityScriptBlueprint.find_by!(container_name: computation.container_name,
                                                 container_tag: computation.container_tag,
                                                 hpc: computation.hpc)

    fill_values = {}
    fill_values[:container_name] = computation.container_name
    fill_values[:container_tag] = computation.container_tag
    fill_values[:hpc] = computation.hpc

    temp = computation.parameter_values&.symbolize_keys
    fill_values = fill_values.merge(temp) unless temp.nil?

    parameters_filled_script = record.script_blueprint % fill_values

    ScriptGenerator.new(@computation, parameters_filled_script).call
  end
end
