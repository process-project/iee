# frozen_string_literal: true

module PipelineStep
  class ParameterOptimization < RimrockBase
    STEP_NAME = 'parameter_optimization'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            'parameter_optimization.sh.erb',
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
      pipeline.data_file(:pressure_drops)
    end
  end
end
