# frozen_string_literal: true

require 'erb'

class SingularityScriptGenerator
  attr_reader :computation

  def initialize(computation, registry_url, container_name, container_tag)
    @computation = computation
    @registry_url = registry_url
    @container_name = container_name
    @container_tag = container_tag
  end

  def call
    # to be replaced later when those params are coming from gui
    mock_params = { tag: @container_tag, hpc: 'Prometheus' }

    record = SingularityScriptBlueprint.find_by!(container_name: @container_name,
                                                 tag: mock_params[:tag],
                                                 hpc: mock_params[:hpc])

    script_options = mock_params.merge(registry_url: @registry_url, container_name: @container_name)

    options_filled_script = record.script_blueprint % script_options

    ScriptGenerator.new(@computation, options_filled_script).call
  end
end
