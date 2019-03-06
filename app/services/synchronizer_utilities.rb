# frozen_string_literal: true

module SynchronizerUtilities
  private

  def case_directory(url)
    File.join(url, 'patients', @patient.case_number)
  end

  def webdav_storage_url
    File.join(Webdav::FileStore.url, Webdav::FileStore.path, Rails.env, '/')
  end

  def parse_response(remote_names)
    sync_dir(remote_names, @patient.inputs_dir)
    @patient.pipelines.includes([:patient]).each do |pipeline|
      sync_dir(remote_names, pipeline.inputs_dir, input_pipeline: pipeline)
      sync_dir(remote_names, pipeline.outputs_dir, output_pipeline: pipeline)
    end
  end

  def sync_dir(remote_names, prefix, input_pipeline: nil, output_pipeline: nil)
    validate_only_one_pipeline!(input_pipeline, output_pipeline)

    file_names = names(remote_names, prefix)

    file_names.each do |remote_name|
      sync_file(remote_name, input_pipeline: input_pipeline, output_pipeline: output_pipeline)
    end
    remove_obsolete_db_entries(file_names,
                               input_pipeline: input_pipeline, output_pipeline: output_pipeline)
  end

  def validate_only_one_pipeline!(input_pipeline, output_pipeline)
    if input_pipeline && output_pipeline
      raise ArgumentError(
        'Arguments input_pipeline and output_pipeline should be mutually exclusive'
      )
    end
  end

  def recognize_data_type(name)
    data_file_types.detect { |dft| dft.match?(name) }&.data_type
  end

  def data_file_types
    @data_file_types ||= DataFileType.all
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

  def names(remote_names, prefix)
    remote_names.select { |rn| rn.split(prefix).size > 1 }.map do |rn|
      rn.split(prefix)[1]
    end
  end

  def sync_file(remote_name, input_pipeline: nil, output_pipeline: nil)
    data_type = recognize_data_type(remote_name)
    if data_type && !current_names(input_pipeline, output_pipeline).include?(remote_name)
      create_db_entry(data_type, remote_name, input_pipeline, output_pipeline)
    end
  end

  def current_names(input_pipeline, output_pipeline)
    @patient.data_files.where(input_of: input_pipeline,
                              output_of: output_pipeline).pluck(:name)
  end

  def create_db_entry(data_type, remote_name, input_pipeline, output_pipeline)
    DataFile.create(name: remote_name, data_type: data_type, patient: @patient,
                    input_of: input_pipeline, output_of: output_pipeline)
  end

  def remove_obsolete_db_entries(remote_names, input_pipeline: nil, output_pipeline: nil)
    @patient.data_files.where(input_of: input_pipeline,
                              output_of: output_pipeline).each do |data_file|
      next if remote_names.include? data_file.name

      data_file.destroy!
      pipeline = input_pipeline || output_pipeline
      Rails.logger.info(
        I18n.t('data_file_synchronizer.file_removed',
               name: data_file.name, patient: @patient.case_number, pipeline: pipeline)
      )
    end
  end
end
