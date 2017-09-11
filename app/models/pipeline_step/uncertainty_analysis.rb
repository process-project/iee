# frozen_string_literal: true

module PipelineStep
  class UncertaintyAnalysis < RimrockBase
    STEP_NAME = 'uncertainty_analysis'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            'uncertainty_analysis.sh.erb',
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
