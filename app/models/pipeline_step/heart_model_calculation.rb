# frozen_string_literal: true

module PipelineStep
  class HeartModelCalculation < RimrockBase
    DEF = RimrockStep.new('heart_model_calculation',
                          'eurvalve/0dmodel',
                          'heart_model.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:estimated_parameters)
    end
  end
end
