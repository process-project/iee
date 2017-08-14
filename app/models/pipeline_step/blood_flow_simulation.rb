# frozen_string_literal: true

module PipelineStep
  class BloodFlowSimulation < RimrockBase
    STEP_NAME = 'blood_flow_simulation'
    REPO_NAME = 'eurvalve/blood-flow'

    def initialize(computation, options = {})
      super(computation, 'eurvalve/blood-flow', 'blood_flow.sh.erb', options)
    end

    def self.create(pipeline)
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        pipeline_step: STEP_NAME
      )
    end

    def runnable?
      pipeline.data_file(:fluid_virtual_model) &&
        pipeline.data_file(:ventricle_virtual_model)
    end
  end
end
