# frozen_string_literal: true

module PipelineStep
  class BloodFlowSimulation < RimrockBase
    STEP_NAME = 'blood_flow_simulation'

    def initialize(computation, options = {})
      super(computation, 'eurvalve/blood-flow', 'blood_flow.sh.erb', options)
    end

    def self.create(pipeline, params)
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        tag_or_branch: tag_or_branch(params),
        pipeline_step: STEP_NAME
      )
    end

    def runnable?
      pipeline.data_file(:fluid_virtual_model) &&
        pipeline.data_file(:ventricle_virtual_model)
    end
  end
end
