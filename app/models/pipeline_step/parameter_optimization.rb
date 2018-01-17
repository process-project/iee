# frozen_string_literal: true

module PipelineStep
  class ParameterOptimization < RimrockBase
    DEF = RimrockStep.new('parameter_optimization',
                          'eurvalve/0dmodel',
                          'parameter_optimization.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:pressure_drops)
    end
  end
end
