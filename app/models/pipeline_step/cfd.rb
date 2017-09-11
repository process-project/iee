# frozen_string_literal: true

module Cfd
  class Cfd < RimrockBase
    STEP_NAME = 'cfd'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/cfd',
            'cfd.sh.erb',
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
