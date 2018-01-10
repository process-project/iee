# frozen_string_literal: true

module PipelineStep
  class Inference < RimrockBase
    STEP_NAME = 'inference'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/mock-step',
            'mock.sh.erb',
            options)
    end

    def self.create(pipeline, params)
      PipelineSteps::Rimrock::Builder.new(pipeline, STEP_NAME, params).call
    end

    def runnable?
      true
    end
  end
end
