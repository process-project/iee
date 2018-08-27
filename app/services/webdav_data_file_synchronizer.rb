# frozen_string_literal: true

require 'net/dav'

class WebdavDataFileSynchronizer
  include SynchronizerUtilities

  def initialize(project, user)
    @dav_client = Webdav::FileStore.new(user)
    @project = project
    @user = user
  end

  # Contacts EurValve file storage and updates the list of DataFiles
  # related to a project.
  def call
    if !@project || @project.project_name.blank?
      report_problem(:no_project_name)
    elsif @user.try(:token).blank?
      report_problem(:no_token)
    elsif @dav_client.blank?
      report_problem(:no_fs_client)
    else
      call_file_storage
    end
  end

  private

  def call_file_storage
    parse_response(remote_file_names)
  rescue Net::HTTPServerException, Net::HTTPFatalError => ex
    response = OpenStruct.new(code: ex.message.to_i, body: ex)
    report_problem(:request_failure, response: response) unless response.code == 404
  rescue SocketError
    report_problem(:no_fs_client)
  end

  def remote_file_names
    remote_names = []
    @dav_client.find(project_directory(webdav_storage_url), recursive: true) do |item|
      remote_names << item.uri.to_s
    end
    remote_names
  end
end
