# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Runner < PipelineSteps::RunnerBase
      def initialize(
          computation,
          registry_url,
          container_name,
          container_tag,
          parameters = [],
          options = {}
      )
        super(computation, options)
        @registry_url = registry_url
        @container_name = container_name
        @container_tag = container_tag
        @parameters = parameters
      end

      protected

      def pre_internal_run
        computation.script = SingularityScriptGenerator.new(
          computation,
          @registry_url,
          @container_name,
          @container_tag
        ).call
        computation.job_id = nil
      end

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
