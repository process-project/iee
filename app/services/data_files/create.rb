# frozen_string_literal: true

module DataFiles
  class Create
    include SynchronizerUtilities

    INPUT_REGEXP = %r{
      \A\/+#{Rails.env}\/patients\/(?<case_number>[^\/]*)\/
      inputs\/(?<path>.*)
    }x
    PIPELINE_INPUT_REGEXP = %r{
      \A\/+#{Rails.env}\/patients\/(?<case_number>[^\/]*)\/
      pipelines\/(?<iid>\d+)\/inputs\/(?<path>.*)
    }x
    PIPELINE_OUTPUT_REGEXP = %r{
      \A\/+#{Rails.env}\/patients\/(?<case_number>[^\/]*)\/
      pipelines\/(?<iid>\d+)\/outputs\/(?<path>.*)
    }x

    def initialize(paths)
      @paths = paths
    end

    def call
      @paths.
        map { |p| data_file_hash(p) }.
        reject(&:blank?).
        group_by { |path_hash| path_hash[:case_number] }.
        flat_map { |case_number, hash| patient_data_file_create(case_number, hash) }.
        compact
    end

    private

    def data_file_hash(path)
      if (match = INPUT_REGEXP.match(path))
        { type: :input, case_number: match[:case_number], path: match[:path] }
      elsif (match = PIPELINE_INPUT_REGEXP.match(path))
        { type: :pipeline_input, iid: match[:iid],
          case_number: match[:case_number], path: match[:path] }
      elsif (match = PIPELINE_OUTPUT_REGEXP.match(path))
        { type: :pipeline_output, iid: match[:iid],
          case_number: match[:case_number], path: match[:path] }
      end
    end

    def patient_data_file_create(case_number, hashes)
      patient = Patient.find_by(case_number: case_number)

      if patient
        patient_inputs_create(patient, hashes) +
          pipelines_data_files_create(patient, hashes)
      else
        []
      end
    end

    def patient_inputs_create(patient, hashes)
      data_files_create(hashes, :input, patient)
    end

    def pipelines_data_files_create(patient, data_file_hashes)
      data_file_hashes.
        reject { |hash| hash[:iid].blank? }.
        group_by { |hash| hash[:iid] }.
        flat_map { |iid, hashes| pipeline_data_files_create(patient, iid, hashes) }
    end

    def pipeline_data_files_create(patient, iid, hashes)
      pipeline = patient.pipelines.find_by(iid: iid)

      if pipeline
        data_files_create(hashes, :pipeline_input, patient, input_of: pipeline) +
          data_files_create(hashes, :pipeline_output, patient, output_of: pipeline)
      else
        []
      end
    end

    def data_files_create(hashes, type, patient, input_of: nil, output_of: nil)
      hashes.
        select { |hash| hash[:type] == type }.
        map do |hash|
          data_file_create(hash, patient, input_of: input_of, output_of: output_of)
        end
    end

    def data_file_create(hash, patient, input_of: nil, output_of: nil)
      if (data_type = recognize_data_type(hash[:path]))
        DataFile.find_or_create_by(name: hash[:path],
                                   data_type: data_type,
                                   patient: patient,
                                   input_of: input_of, output_of: output_of)
      end
    end
  end
end
