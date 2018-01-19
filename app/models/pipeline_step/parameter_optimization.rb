# frozen_string_literal: true

module PipelineStep
  class ParameterOptimization < RimrockBase
    DEF = RimrockStep.new('parameter_optimization',
                          'eurvalve/0dmodel',
                          'parameter_optimization.sh.erb',
                          [:pressure_drops])

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      DEF.runnable_for?(computation)
    end
  end
end
