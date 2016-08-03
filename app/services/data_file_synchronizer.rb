# frozen_string_literal: true
class DataFileSynchronizer < ProxyService
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

  private

  def call_file_storage
    response = connection.get(@patient.case_number)

    case response.status
    when 200 then
      parse_response(response.body)
    when 408 then
      report_problem(:timed_out, response: response)
    else
      report_problem(:request_failure, response: response)
    end
  end

  def storage_url
    Rails.application.config_for('eurvalve')['storage_url']
  end

  def parse_response(body)
    remote_names = []
    current_names = @patient.data_files.pluck(:name)

    # Add DataFiles that are not yet present for @patient
    files(body).each do |file|
      data_type = recognize_data_type(file['name'])
      next unless data_type
      create_db_entry(data_type, file) unless current_names.include?(file['name'])
      remote_names << file['name']
    end

    remove_obsolete_db_entries(remote_names)
  end

  def create_db_entry(data_type, file)
    DataFile.create(name: file['name'],
                    data_type: data_type,
                    handle: construct_handle(file['name']),
                    patient: @patient)
  end

  def files(body)
    JSON.parse(body).reject! { |f| f['is_dir'] }
  end

  def remove_obsolete_db_entries(remote_names)
    @patient.data_files.each do |data_file|
      next if remote_names.include? data_file.name
      data_file.destroy!
      Rails.logger.info(
        I18n.t('data_file_synchronizer.file_removed',
               name: data_file.name,
               patient: @patient.case_number)
      )
    end
  end

  def construct_handle(filename)
    case_directory = Rails.application.config_for('eurvalve')['handle_url']
    case_directory += '/' unless case_directory.end_with?('/')
    case_directory += @patient.case_number
    case_directory + '/' + filename
  end

  def recognize_data_type(name)
    case name
    when 'fluidFlow.cas' then 'fluid_virtual_model'
    when 'structural_vent.dat' then 'ventricle_virtual_model'
    when /fluidFlow.*.dat/ then 'blood_flow_result'
    when /fluidFlow.*.cas/ then 'blood_flow_model'
    end
  end

  def report_problem(problem, details = {})
    details.merge!(extra_details(details))

    # TODO: FIXME Add Raven Sentry notification; issue #32

    Rails.logger.tagged(self.class.name) do
      Rails.logger.warn I18n.t("data_file_synchronizer.#{problem}", details)
      Rails.logger.info(details[:response].body) if details[:response]
    end
  end

  def extra_details(details)
    {
      patient: @patient.try(:case_number),
      user: @user.try(:name),
      code: details[:response].try(:code)
    }
  end
end
