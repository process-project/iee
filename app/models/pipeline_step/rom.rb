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

    def self.create(pipeline, params)
      PipelineSteps::Rimrock::Builder.new(pipeline, STEP_NAME, params).call
    end

    def runnable?
      pipeline.data_file(:response_surface)
    end
  end
end
