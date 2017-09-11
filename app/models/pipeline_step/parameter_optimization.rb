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

    def self.create(pipeline)
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        pipeline_step: STEP_NAME
      )
    end

    def runnable?
      pipeline.data_file(:off_mesh)
    end
  end
end
