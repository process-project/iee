# frozen_string_literal: true
module PipelineStep
  class Segmentation
    def initialize(patient, user)
      validate_procedure_status!(patient)
      @patient = patient
      @computation = WebdavComputation.create!(
        patient: patient,
        user: user,
        pipeline_step: 'imaging_uploaded',
        input_path: input_path,
        output_path: output_path
      )
    end

    def run
      Webdav::StartJob.perform_later @computation
      @computation
    end

    private_class_method

    def validate_procedure_status!(patient)
      statuses = Patient.procedure_statuses
      imaging_uploaded = statuses[patient.procedure_status] >= statuses['imaging_uploaded']
      raise('Patient imaging must be uploaded to run Segmentation') unless imaging_uploaded
    end

    def input_path
      "/#{Rails.env}/patients/#{@patient.case_number}/imaging_#{@patient.case_number}.zip"
    end

    def output_path
      "/#{Rails.env}/patients/#{@patient.case_number}/segmentation_#{@patient.case_number}.zip"
    end
  end
end