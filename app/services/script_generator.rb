# frozen_string_literal: true

require 'erb'

class ScriptGenerator
  attr_reader :computation

  delegate :pipeline, to: :computation
  delegate :user, to: :pipeline
  delegate :revision, to: :computation
  delegate :patient, to: :pipeline

  def initialize(computation, template)
    @computation = computation
    @template = template
  end

  def call
    @template && ERB.new(@template, nil, '-').result(binding)
  end

  def grant_id
    Rails.application.config_for('eurvalve')['grant_id']
  end

  def ssh_download_key
    File.read(Rails.application.config_for('eurvalve')['git_download_key'])
  end

  def stage_in(options = {})
    if options.keys.include?(:data_file_type)
      filename, url = extract_request_data_for_type(options)
    elsif options.keys.include?(:path)
      filename, url = extract_request_data_for_path(options)
    else
      Rails.logger.error('stage_in needs either data_file_type or path in argument hash.')
      raise ArgumentError, 'stage_in needs either data_file_type or path in argument hash.'
    end

    "curl -H \"Authorization: Bearer #{user.token}\""\
      " \"#{url}\" >> \"$SCRATCHDIR/#{filename}\""
  end

  def stage_out(relative_path, filename = nil)
    filename ||= File.basename(relative_path)

    "curl -X PUT --data-binary @#{relative_path} "\
      '-H "Content-Type:application/octet-stream"'\
      " -H \"Authorization: Bearer #{user.token}\""\
      " \"#{File.join(pipeline.working_url, filename)}\""
  end

  private

  def extract_request_data_for_type(options)
    data_file = pipeline.data_file(options[:data_file_type])
    filename = options[:filename] || data_file&.name
    url = data_file.url
    [filename, url]
  end

  def extract_request_data_for_path(options)
    url = File.join(Webdav::FileStore.url, Webdav::FileStore.path, options[:path])
    filename = options[:filename] || File.basename(options[:path])
    [filename, url]
  end
end
