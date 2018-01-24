# frozen_string_literal: true

module PipelineStep
  class UncertaintyAnalysis < Base
    DEF = RimrockStep.new('uncertainty_analysis',
                          'eurvalve/0dmodel',
                          'uncertainty_analysis.sh.erb',
                          [:parameter_optimization_result])

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
