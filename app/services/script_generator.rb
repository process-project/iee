# frozen_string_literal: true

require 'liquid'

class ScriptGenerator
  attr_reader :computation

  delegate :pipeline, :revision, to: :computation
  delegate :patient, :user, :mode, to: :pipeline
  delegate :token, :email, to: :user
  delegate :case_number, to: :patient

  def initialize(computation, template)
    @computation = computation
    @template = template
  end

  def call
    if @template
      parsed_template = Liquid::Template.parse(@template)
      parsed_template.render({ 'token' => token, 'email' => email, 'case_number' => case_number,
                               'revision' => revision, 'grant_id' => grant_id, 'mode' => mode,
                               'setup_ansys_licenses' => setup_ansys_licenses,
                               'pipeline_identifier' => pipeline_identifier },
                             registers: { pipeline: pipeline })
    end
  end

  def grant_id
    Rails.application.config_for('eurvalve')['grant_id']
  end

  def pipeline_identifier
    "#{case_number}-#{pipeline.iid}"
  end

  def setup_ansys_licenses
    <<~LICENSE_EXPORT
      export ANSYSLI_SERVERS=#{ansys_servers}
      export ANSYSLMD_LICENSE_FILE=#{ansys_license_file}
    LICENSE_EXPORT
  end

  private

  def ansys_servers
    Rails.application.config_for('application')['ansys']['servers']
  end

  def ansys_license_file
    Rails.application.config_for('application')['ansys']['license_file']
  end
end
