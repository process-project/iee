# frozen_string_literal: true

module PipelineSteps
  module Rimrock
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, repository, file, options = {})
        super(computation, options)
        @repository = repository
        @file = file
      end

      def self.tag_or_branch(params)
        params.fetch(:tag_or_branch) { nil }
      end

      protected

      def pre_internal_run
        computation.revision = revision
        computation.script = ScriptGenerator.new(computation, template).call
        computation.job_id = nil
      end

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end
    end
  end
end
