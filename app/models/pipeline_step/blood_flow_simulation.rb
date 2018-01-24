# frozen_string_literal: true

module PipelineStep
  class BloodFlowSimulation < Base
    DEF = RimrockStep.new('blood_flow_simulation',
                          'eurvalve/blood-flow',
                          'blood_flow.sh.erb',
                          [:fluid_virtual_model,
                           :ventricle_virtual_model])

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
