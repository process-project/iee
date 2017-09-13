# frozen_string_literal: true

module SynchronizerUtilities
  private

  TYPE_PATTERNS = {
    /^imaging_.*\.zip$/ => 'image',
    /^segmentation_.*\.zip$/ => 'segmentation_result',
    /^fluidFlow\.cas$/ => 'fluid_virtual_model',
    /^structural_vent\.dat$/ => 'ventricle_virtual_model',
    /^fluidFlow.*\.dat$/ => 'blood_flow_result',
    /^fluidFlow.*\.cas$/ => 'blood_flow_model',
    /^0DModel_input\.csv$/ => 'estimated_parameters',
    /^Outfile\.csv$/ => 'heart_model_output',
    /^.*Trunc\.off$/ => 'truncated_off_mesh',
    /^.*\.off$/ => 'off_mesh',
    /^.*\.\b(png|bmp|jpg)\b$/ => 'graphics',
    /^.*\.dxrom$/ => 'response_surface',
    /^ValveChar\.csv$/ => 'pressure_drops',
    /^OutFileGA\.csv$/ => 'parameter_optimization_result',
    /^Outseries1\.csv$/ => 'data_series_1',
    /^Outseries2\.csv$/ => 'data_series_2',
    /^Outseries3\.csv$/ => 'data_series_3',
    /^Outseries4\.csv$/ => 'data_series_4'
  }.freeze

  def case_directory(url)
    File.join(url, 'patients', @patient.case_number)
  end

  def webdav_storage_url
    File.join(Webdav::FileStore.url, Webdav::FileStore.path, Rails.env, '/')
  end

  def parse_response(remote_names)
    input_names(remote_names).each do |remote_name|
      sync_file(remote_name)
    end
    remove_obsolete_db_entries(input_names(remote_names))

    @patient.pipelines.each do |pipeline|
      pipeline_file_names(remote_names, pipeline).each do |remote_name|
        sync_file(remote_name, pipeline)
      end
      remove_obsolete_db_entries(pipeline_file_names(remote_names, pipeline), pipeline)
    end
  end

  def recognize_data_type(name)
    TYPE_PATTERNS.detect { |k, _| name =~ k }&.[](1)
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

  def current_names(pipeline)
    @patient.data_files.where(pipeline: pipeline).pluck(:name)
  end

  def input_names(remote_names)
    remote_names.select { |rn| rn.split(@patient.inputs_dir).size > 1 }.map do |rn|
      rn.split(@patient.inputs_dir)[1]
    end
  end

  def pipeline_file_names(remote_names, pipeline)
    remote_names.select { |rn| rn.split(pipeline.working_dir).size > 1 }.map do |rn|
      rn.split(pipeline.working_dir)[1]
    end
  end

  def sync_file(remote_name, pipeline = nil)
    data_type = recognize_data_type(remote_name)
    if data_type && !current_names(pipeline).include?(remote_name)
      create_db_entry(data_type, remote_name, pipeline)
    end
  end

  def create_db_entry(data_type, remote_name, pipeline)
    DataFile.create(name: remote_name,
                    data_type: data_type,
                    patient: @patient,
                    pipeline: pipeline)
  end

  def remove_obsolete_db_entries(remote_names, pipeline = nil)
    @patient.data_files.where(pipeline: pipeline).each do |data_file|
      next if remote_names.include? data_file.name
      data_file.destroy!
      Rails.logger.info(
        I18n.t('data_file_synchronizer.file_removed',
               name: data_file.name,
               patient: @patient.case_number,
               pipeline: pipeline)
      )
    end
  end
end
