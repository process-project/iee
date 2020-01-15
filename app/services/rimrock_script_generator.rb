# frozen_string_literal: true

class RimrockScriptGenerator
  def initialize(computation, template)
    @computation = computation
    @template = template
  end

  def call
    fill_values = computation_parameter_values

    Rails.logger.debug("+++COMPUTATION: #{@computation.inspect}")
    Rails.logger.debug("+++FILL VALUES: #{fill_values.inspect}")
    Rails.logger.debug("+++PARAM VALUES: #{@computation.parameter_values.inspect}")

    #filled_script = @template % fill_values
    filled_script = @template

    # Neede for now, we sometimes use functionality of the old ScriptGenerator in our scripts
    # e.g for staging in/out to/from webdav
    ScriptGenerator.new(@computation, filled_script).call
  end

  private

  def computation_parameter_values
    fill_values = {}
    fill_values[:container_name] = @computation.container_name
    fill_values[:container_tag] = @computation.container_tag
    fill_values[:hpc] = @computation.hpc

    temp = @computation.parameter_values&.symbolize_keys
    fill_values = fill_values.merge(temp) unless temp.nil?

    fill_values
  end
end
