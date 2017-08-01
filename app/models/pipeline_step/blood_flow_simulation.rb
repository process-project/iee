# frozen_string_literal: true

module PipelineStep
  class BloodFlowSimulation < Base
    STEP_NAME = 'blood_flow_simulation'

    def initialize(computation, options = {})
      super(computation)
      @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
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

    def pre_internal_run
      computation.script = ScriptGenerator.new(computation, template).call
      computation.job_id = nil
    end

    def internal_run
      Rimrock::StartJob.perform_later computation if computation.valid?
    end

    def template
      @template_fetcher.new('eurvalve/blood-flow',
                            'blood_flow.sh.erb',
                            computation.revision).call
    end
  end
end
