# frozen_string_literal: true

require 'erb'

class ScriptGenerator
  attr_reader :pipeline
  delegate :user, to: :pipeline

  def initialize(pipeline, template)
    @pipeline = pipeline
    @template = template
  end

  def call
    ERB.new(@template, nil, '-').result(binding)
  end

  def grant_id
    Rails.application.config_for('eurvalve')['grant_id']
  end

  def stage_in(data_file_type, filename = nil)
    data_file = pipeline.data_file(data_file_type)
    filename ||= data_file&.name

    "curl -H \"Authorization: Bearer #{user.token}\""\
      " \"#{data_file.url}\" >> \"$SCRATCHDIR/#{filename}\""
  end

  def stage_out(relative_path, filename = nil)
    filename ||= File.basename(relative_path)

    "curl -X PUT --data-binary @#{relative_path} "\
      '-H \"Content-Type:application/octet-stream\"'\
      " -H \"Authorization: Bearer #{user.token}\""\
      " \"#{File.join(pipeline.working_url, filename)}\""
  end
end
