# frozen_string_literal: true

module PipelineStep
  class ValvePlacement < Base
    DEF = RimrockStep.new('valve_placement',
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
