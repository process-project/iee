# frozen_string_literal: true

require 'erb'

class SingularityScriptGenerator
  attr_reader :computation

  def initialize(computation)
    @computation = computation
  end

  def call
    parameter_values = computation.parameter_values
    record = SingularityScriptBlueprint.find_by!(container_name: computation.container_name,
                                                 container_tag: computation.container_tag,
                                                 hpc: computation.hpc)

    parameters_filled_script = record.script_blueprint % parameter_values

    ScriptGenerator.new(@computation, parameters_filled_script).call
  end
end
