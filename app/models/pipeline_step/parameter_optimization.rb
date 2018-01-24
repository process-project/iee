# frozen_string_literal: true

module PipelineStep
  class ParameterOptimization < Base
    DEF = RimrockStep.new('parameter_optimization',
                          'eurvalve/0dmodel',
                          'parameter_optimization.sh.erb',
                          [:pressure_drops])

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
