# frozen_string_literal: true
module SynchronizerUtilities
  private

  def case_directory(url)
    "#{url}patients/#{@patient.case_number}"
  end

  def construct_handle(handle_url, filename)
    "#{case_directory(handle_url)}/#{filename}"
  end

  def parse_response(handle_url, remote_names)
    current_names = @patient.data_files.pluck(:name)

    # Add DataFiles that are not yet present for @patient
    remote_names.each do |remote_name|
      data_type = recognize_data_type(remote_name)
      next unless data_type
      create_db_entry(handle_url, data_type, remote_name) unless current_names.include?(remote_name)
    end

    remove_obsolete_db_entries(remote_names)
  end

  def create_db_entry(handle_url, data_type, remote_name)
    DataFile.create(name: remote_name,
                    data_type: data_type,
                    handle: construct_handle(handle_url, remote_name),
                    patient: @patient)
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

  # rubocop:disable CyclomaticComplexity
  def recognize_data_type(name)
    case name
    when 'fluidFlow.cas' then 'fluid_virtual_model'
    when 'structural_vent.dat' then 'ventricle_virtual_model'
    when /fluidFlow.*.dat/ then 'blood_flow_result'
    when /fluidFlow.*.cas/ then 'blood_flow_model'
    when '0DModel_input.csv' then 'estimated_parameters'
    when 'Outfile.csv' then 'heart_model_output'
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

  def extra_details(details = {})
    {
      patient: @patient.try(:case_number),
      user: @user.try(:name),
      code: details[:response].try(:code)
    }
  end
end
