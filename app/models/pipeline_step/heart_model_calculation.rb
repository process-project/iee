# frozen_string_literal: true

module PipelineStep
  class HeartModelCalculation < Base
    STEP_NAME = 'heart_model_calculation'

    def initialize(pipeline, options = {})
      super(pipeline, STEP_NAME)
      @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
    end

    def create
      RimrockComputation.create(
        pipeline: pipeline,
        user: pipeline.user,
        pipeline_step: pipeline_step
      )
    end

    def runnable?
      pipeline.data_file(:estimated_parameters)
    end

    protected

    def pre_internal_run
      computation.script = ScriptGenerator.new(computation, template).call
      computation.job_id = nil
    end

    def internal_run
      Rimrock::StartJob.perform_later computation if computation.valid?
    end

    def template
      @template_fetcher.new('eurvalve/0dmodel',
                            'heart_model.sh.erb',
                            computation.revision).call
    end
  end
end
