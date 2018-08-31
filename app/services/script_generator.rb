# frozen_string_literal: true

require 'erb'

class ScriptGenerator
  attr_reader :computation

  delegate :pipeline, to: :computation
  delegate :project, to: :pipeline
  delegate :user, to: :pipeline
  delegate :revision, to: :computation
  delegate :project, to: :pipeline
  delegate :token, to: :user
  delegate :project_name, to: :project

  def initialize(computation, template)
    @computation = computation
    @template = template
  end

  def call
    @template && ERB.new(@template, nil, '-').result(binding)
  end

  def grant_id
    Rails.application.config_for('process')['grant_id']
  end

  def ssh_download_key
    File.read(Rails.application.config_for('process')['git_download_key'])
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

    "curl -H \"Authorization: Bearer #{token}\" \"#{url}\" "\
      ">> \"$SCRATCHDIR/#{filename}\" #{'--fail' unless options[:optional]}"
  end

  def stage_out(relative_path, filename = nil)
    filename ||= File.basename(relative_path)

    "curl -X PUT --data-binary @#{relative_path} "\
      '-H "Content-Type:application/octet-stream"'\
      " -H \"Authorization: Bearer #{token}\""\
      " \"#{File.join(pipeline.outputs_url, filename)}\""
  end

  def pipeline_identifier
    "#{project.project_name}-#{pipeline.iid}"
  end

  def setup_ansys_licenses
    <<~LICENSE_EXPORT
      export ANSYSLI_SERVERS=#{ansys_servers}
      export ANSYSLMD_LICENSE_FILE=#{ansys_license_file}
    LICENSE_EXPORT
  end

  def gitlab_clone_url
    Rails.application.config_for('application')['gitlab']['clone_url']
  end

  def clone_repo(repo)
    <<~CODE
      export SSH_DOWNLOAD_KEY="#{ssh_download_key}"
      ssh-agent bash -c '
        ssh-add <(echo "$SSH_DOWNLOAD_KEY");
        git clone #{gitlab_clone_url}:#{repo}'
    CODE
  end

  private

  def ansys_servers
    Rails.application.config_for('application')['ansys']['servers']
  end

  def ansys_license_file
    Rails.application.config_for('application')['ansys']['license_file']
  end

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
