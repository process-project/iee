# frozen_string_literal: true

module PipelineSteps
  module Singularity
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, registry_url, container_name, options)
        super(computation, options)
        @registry_url = registry_url
        @container_name = container_name
      end

      protected

      def pre_internal_run
        computation.script = SingularityScriptGenerator.new(computation, @registry_url, @container_name).call
      end

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
