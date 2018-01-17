# frozen_string_literal: true

module PipelineStep
  class BloodFlowSimulation < RimrockBase
    DEF = RimrockStep.new('blood_flow_simulation',
                          'eurvalve/blood-flow',
                          'blood_flow.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:fluid_virtual_model) &&
        pipeline.data_file(:ventricle_virtual_model)
    end
  end
end
