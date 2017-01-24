# frozen_string_literal: true
class PlgridDataFileSynchronizer < ProxyService
  include SynchronizerUtilities

  def initialize(patient, user, options = {})
    super(user, options[:storage_url] || storage_url, options)
    @patient = patient
    @user = user
  end

  # Contacts EurValve file storage and updates the list of DataFiles
  # related to a patient.
  def call
    if !@patient || @patient.case_number.blank?
      report_problem(:no_case_number)
    elsif @proxy.blank?
      report_problem(:no_proxy)
    else
      call_file_storage
    end
  rescue
    report_problem(:invalid_response)
  end

  def computation_file_handle(filename)
    "$PLG_GROUPS_STORAGE/plggeurvalve/#{Rails.env}/patients/#{@patient.case_number}/#{filename}"
  end

  private

  def call_file_storage
    response = connection.get(@patient.case_number)

    case response.status
    when 200 then
      parse_response(handle_url, file_names(response.body))
    when 408 then
      report_problem(:timed_out, response: response)
    else
      report_problem(:request_failure, response: response)
    end
  end

  def storage_url
    Rails.application.config_for('eurvalve')['storage_url'] + 'patients/'
  end

  def handle_url
    Rails.application.config_for('eurvalve')['handle_url']
  end

  def file_names(body)
    JSON.parse(body).reject! { |f| f['is_dir'] }.map { |f| f['name'] }
  end
end
