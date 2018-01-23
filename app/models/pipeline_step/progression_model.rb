# frozen_string_literal: true

module PipelineStep
  class ProgressionModel < Base
    DEF = RimrockStep.new('progression_model',
                          'eurvalve/mock-step',
                          'mock.sh.erb')

    def initialize(computation, options = {})
      super(computation, options)
    end

    def runnable?
      DEF.runnable_for?(computation)
    end

    protected

    def runner
      DEF.runner_for(computation, options)
    end
  end
end
