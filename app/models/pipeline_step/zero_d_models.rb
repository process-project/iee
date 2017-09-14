# frozen_string_literal: true

module PipelineStep
  class ZeroDModels < RimrockBase
    STEP_NAME = '0d_models'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            '0d_scenarios.sh.erb',
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
      pipeline.data_file(:parameter_optimization_result)
    end
  end
end
