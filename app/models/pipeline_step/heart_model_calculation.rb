# frozen_string_literal: true
module PipelineStep
  class HeartModelCalculation < Base
    STEP_NAME = 'heart_model_calculation'

    def initialize(pipeline)
      super(pipeline, STEP_NAME)
    end

    def create
      RimrockComputation.create(
        pipeline: pipeline,
        user: user,
        pipeline_step: pipeline_step,
        script: ScriptGenerator::HeartModel.new(pipeline.patient, user).call
      )
    end

    def runnable?
      pipeline.data_file(:estimated_parameters)
    end

    protected

    def internal_run
      Rimrock::StartJob.perform_later computation
    end
  end
end
