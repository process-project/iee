# frozen_string_literal: true

module PipelineStep
  class ParameterExtraction < RimrockBase
    STEP_NAME = 'parameter_extraction'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/parameter-extraction',
            'parameter_extraction.sh.erb',
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
      pipeline.data_file(:off_mesh)
    end
  end
end
