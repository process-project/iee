# frozen_string_literal: true
module PipelineStep
  class Segmentation < PipelineStep::Base
    STEP_NAME = 'segmentation'

    def initialize(pipeline)
      super(pipeline, STEP_NAME)
    end

    def create
      WebdavComputation.create!(
        pipeline: pipeline,
        user: user,
        pipeline_step: pipeline_step,
        output_path: output_path
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

    def output_path
      File.join(@pipeline.working_dir, 'segmentation.zip')
    end
  end
end
