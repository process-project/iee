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
      PipelineSteps::Rimrock::Builder.new(pipeline, STEP_NAME, params).call
    end

    def runnable?
      pipeline.data_file(:off_mesh)
    end
  end
end
