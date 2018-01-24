# frozen_string_literal: true

module PipelineStep
  class InferenceWeighting < Base
    DEF = RimrockStep.new('inference_weighting',
                          'eurvalve/mock-step',
                          'mock.sh.erb')

    def initialize(computation, options = {})
      super(computation, options)
    end

    def runnable?
      DEF.runnable_for?(pipeline)
    end

    protected

    def runner
      DEF.runner_for(computation, options)
    end
  end
end
