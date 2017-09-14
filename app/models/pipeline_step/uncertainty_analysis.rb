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

    def self.create(pipeline, params)
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        tag_or_branch: tag_or_branch(params),
        pipeline_step: STEP_NAME
      )
    end

    def runnable?
      pipeline.data_file(:data_series_1)
    end
  end
end
