# frozen_string_literal: true

module PipelineStep
  class UncertaintyAnalysis < RimrockBase
    STEP_NAME = 'uncertainty_analysis'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            'uncertainty_analysis.sh.erb',
            options)
    end

    def self.create(pipeline, params)
      PipelineSteps::Rimrock::Builder.new(pipeline, STEP_NAME, params).call
    end

    def runnable?
      pipeline.data_file(:parameter_optimization_result)
    end
  end
end
