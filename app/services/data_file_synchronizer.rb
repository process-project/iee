require 'base64'
require 'faraday'

class DataFileSynchronizer
  def initialize(patient, user, options = {})
    @patient = patient
    @user = user
    @proxy = encode_proxy user.try(:proxy)

    @connection = options[:connection]
    @storage_url = options[:storage_url] ||
                   Rails.application.config_for('eurvalve')['storage_url']
  end

  # Contacts EurValve file storage and updates the list of DataFiles
  # related to a patient.
  def call
    if !@patient || @patient.case_number.blank?
      report_problem(:no_case_number)
    elsif @proxy.blank?
      report_problem(:no_proxy)
    else
      response = connection.get(@patient.case_number)

      case response.status
        when 200 then parse_response(response.body)
        when 408 then report_problem(:timed_out, response: response)
        else report_problem(:request_failure, response: response)
      end
    end
  rescue
    report_problem(:invalid_response)
  end

  private

  def parse_response(body)
    remote_names = []
    current_names = @patient.data_files.pluck(:name)

    # Add DataFiles that are not yet present for @patient
    JSON.parse(body).each do |file|
      next if file['is_dir']
      data_type = recognize_data_type(file['name'])
      if data_type
        unless current_names.include?(file['name'])
          DataFile.create(name: file['name'],
                          data_type: data_type,
                          handle: construct_handle(file['name']),
                          patient: @patient)
        end
        remote_names << file['name']
      end
    end

    # Remove DataFiles which are no longer stored
    @patient.data_files.each do |data_file|
      unless remote_names.include? data_file.name
        data_file.destroy!
        Rails.logger.info(
          I18n.t('data_file_synchronizer.file_removed',
                 name: data_file.name,
                 patient: @patient.case_number)
        )
      end
    end
  end

  def construct_handle(filename)
    case_directory = Rails.application.config_for('eurvalve')['handle_url']
    case_directory += '/' unless case_directory.end_with?('/')
    case_directory += @patient.case_number
    case_directory + '/' + filename
  end

  def encode_proxy(proxy)
    proxy ? Base64.encode64(proxy).gsub!(/\s+/, '') : nil
  end

  def recognize_data_type(name)
    case name
    when 'fluidFlow.cas' then 'fluid_virtual_model'
    when 'structural_vent.dat' then 'ventricle_virtual_model'
    else nil
    end
  end

  def report_problem(problem, details = {})
    details.merge!({
      patient: @patient.try(:case_number),
      user: @user.try(:name),
      code: details[:response].try(:code)
    })

    # TODO FIXME Add Raven Sentry notification; issue #32

    Rails.logger.tagged(self.class.name) do
      Rails.logger.warn I18n.t("data_file_synchronizer.#{problem}", details)
      Rails.logger.info(details[:response].body) if details[:response]
    end
  end

  def connection
    @connection ||= Faraday.new(url: @storage_url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.headers['PROXY'] = @proxy
    end
  end
end
