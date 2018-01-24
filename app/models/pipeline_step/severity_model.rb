# frozen_string_literal: true

module PipelineStep
  class SeverityModel < Base
    DEF = RimrockStep.new('severity_model',
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
