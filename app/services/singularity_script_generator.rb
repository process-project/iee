# frozen_string_literal: true

require 'erb'

class SingularityScriptGenerator
  attr_reader :computation

  def initialize(computation, user_parameters)
    @computation = computation
    @user_parameters = user_parameters
  end

  def call
    record = SingularityScriptBlueprint.find_by!(container_name: @user_parameters[:container_name],
                                                 tag: @user_parameters[:container_tag],
                                                 hpc: @user_parameters[:hpc])

    options_filled_script = record.script_blueprint % @user_parameters

    ScriptGenerator.new(@computation, options_filled_script).call
  end
end
