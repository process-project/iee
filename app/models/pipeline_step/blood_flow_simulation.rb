# frozen_string_literal: true
module PipelineStep
  class BloodFlowSimulation < Base
    STEP_NAME = 'blood_flow_simulation'

    def initialize(pipeline, options = {})
      super(pipeline, STEP_NAME)
      @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
    end

    def create
      RimrockComputation.create(
        pipeline: pipeline,
        user: user,
        pipeline_step: pipeline_step
      )
    end

    def runnable?
      pipeline.data_file(:fluid_virtual_model) &&
        pipeline.data_file(:ventricle_virtual_model)
    end

    def internal_run
      computation.script = ScriptGenerator.new(computation, template).call
      computation.job_id = nil
      computation.save!

      Rimrock::StartJob.perform_later computation
    end

    def template
      @template_fetcher.new('eurvalve/blood-flow',
                            'blood_flow.sh.erb',
                            computation.revision).call
    end
  end
end
