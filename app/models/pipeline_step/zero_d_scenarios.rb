# frozen_string_literal: true

module PipelineStep
  class ZeroDScenarios < RimrockBase
    STEP_NAME = '0d_scenarios'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            '0d_scenarios.sh.erb',
            options)
    end

    def self.create(pipeline)
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        pipeline_step: STEP_NAME
      )
    end

    def runnable?
      pipeline.data_file(:parameter_optimization_result)
    end
  end
end
