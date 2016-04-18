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

  def storage_url
    Rails.application.config_for('eurvalve')['storage_url']
  end

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
end
