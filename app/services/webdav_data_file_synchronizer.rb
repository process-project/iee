require 'net/dav'

# frozen_string_literal: true
class WebdavDataFileSynchronizer
  include SynchronizerUtilities

  def initialize(patient, user)
    @dav_client = Net::DAV.new(
      storage_url,
      headers: {
        'Authorization' => "Bearer #{user.try(:token)}"
      }
    )
    @patient = patient
    @user = user
  end

  # Contacts EurValve file storage and updates the list of DataFiles
  # related to a patient.
  def call
    if !@patient || @patient.case_number.blank?
      report_problem(:no_case_number)
    elsif @user.try(:token).blank?
      report_problem(:no_token)
    elsif @dav_client.blank?
      report_problem(:no_fs_client)
    else
      call_file_storage
    end
  end

  def computation_file_handle(filename)
    construct_handle(storage_url, filename)
  end

  private

  def call_file_storage
    parse_response(storage_url, remote_file_names)
  rescue Net::HTTPServerException => ex
    response = OpenStruct.new(code: ex.message.to_i, body: ex)
    report_problem(:request_failure, response: response) unless response.code == 404
  rescue SocketError
    report_problem(:no_fs_client)
  end

  def remote_file_names
    remote_names = []
    @dav_client.find(case_directory(storage_url), recursive: false) do |item|
      remote_names << item.properties.displayname
    end
    remote_names
  end

  def storage_url
    Rails.configuration.constants['file_store']['web_dav_base_url'] +
      Rails.configuration.constants['file_store']['web_dav_base_path'] +
      "/#{Rails.env}/"
  end
end
