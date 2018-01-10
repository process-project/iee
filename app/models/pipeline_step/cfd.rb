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
      PipelineSteps::Rimrock::Builder.new(pipeline, STEP_NAME, params).call
    end

    def runnable?
      pipeline.data_file(:truncated_off_mesh)
    end
  end
end
