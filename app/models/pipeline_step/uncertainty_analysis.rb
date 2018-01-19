# frozen_string_literal: true

module PipelineStep
  class UncertaintyAnalysis < RimrockBase
    DEF = RimrockStep.new('uncertainty_analysis',
                          'eurvalve/0dmodel',
                          'uncertainty_analysis.sh.erb',
                          [:parameter_optimization_result])

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
