# frozen_string_literal: true

module PipelineStep
  class HeartModelCalculation < Base
    DEF = RimrockStep.new('heart_model_calculation',
                          'eurvalve/0dmodel',
                          'heart_model.sh.erb',
                          [:estimated_parameters])

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
