# frozen_string_literal: true

module PipelineStep
  class ZeroDModels < Base
    DEF = RimrockStep.new('0d_models',
                          'eurvalve/0dmodel',
                          '0d_scenarios.sh.erb',
                          [:parameter_optimization_result])

    def initialize(computation, options = {})
      super(computation, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
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
