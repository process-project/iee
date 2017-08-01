# frozen_string_literal: true

module PipelineStep
  class Segmentation < PipelineStep::Base
    STEP_NAME = 'segmentation'

    def initialize(computation, _options = {})
      super(computation)
    end

    def self.create(pipeline)
      WebdavComputation.create!(
        pipeline: pipeline,
        user: pipeline.user,
        pipeline_step: STEP_NAME,
        output_path: pipeline.working_dir
      )
    end

    def runnable?
      image_data_file
    end

    protected

    def internal_run
      computation.tap do |c|
        c.update_attributes(input_path: image_data_file.path)
        Webdav::StartJob.perform_later(c)
      end
    end

    private

    def image_data_file
      pipeline.data_file(:image)
    end

    def validate_procedure_status!(patient)
      statuses = Patient.procedure_statuses
      imaging_uploaded = statuses[patient.procedure_status] >= statuses['imaging_uploaded']
      raise('Patient imaging must be uploaded to run Segmentation') unless imaging_uploaded
    end

    def input_path
      File.join(@patient.working_dir, "imaging_#{@patient.case_number}.zip")
    end
  end
end
