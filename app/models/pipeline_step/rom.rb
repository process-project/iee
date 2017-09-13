# frozen_string_literal: true

module PipelineStep
  class Rom < RimrockBase
    STEP_NAME = 'rom'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/cfd',
            'rom.sh.erb',
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
      pipeline.data_file(:response_surface)
    end
  end
end
