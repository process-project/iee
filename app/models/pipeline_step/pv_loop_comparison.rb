# frozen_string_literal: true

module PipelineStep
  class PvLoopComparison < RimrockBase
    STEP_NAME = 'pv_loop_comparison'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/mock-step',
            'mock.sh.erb',
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
      true
    end
  end
end
