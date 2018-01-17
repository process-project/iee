# frozen_string_literal: true

module PipelineStep
  class ZeroDModels < RimrockBase
    DEF = RimrockStep.new('0d_models',
                          'eurvalve/0dmodel',
                          '0d_scenarios.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:parameter_optimization_result)
    end
  end
end
