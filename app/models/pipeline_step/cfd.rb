# frozen_string_literal: true

module PipelineStep
  class Cfd < RimrockBase
    STEP_NAME = 'cfd'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/cfd',
            'cfd.sh.erb',
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
      pipeline.data_file(:truncated_off_mesh)
    end
  end
end
