# frozen_string_literal: true

module PipelineStep
  class HeartModelCalculation < RimrockBase
    STEP_NAME = 'heart_model_calculation'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            'heart_model.sh.erb',
            options)
    end

    def self.create(pipeline, params)
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        tag_or_branch: tag_or_branch(params),
        pipeline_step: STEP_NAME
      )
    end

    def runnable?
      pipeline.data_file(:estimated_parameters)
    end
  end
end
