# frozen_string_literal: true

module PipelineSteps
  module Rimrock
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, repository, file, options = {})
        super(computation, options)
        @repository = repository
        @file = file
        @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
        @revision_fetcher = options.fetch(:revision_fetcher) { Gitlab::Revision }
      end

      def self.tag_or_branch(params)
        params.fetch(:tag_or_branch) { nil }
      end

      protected

      def pre_internal_run
        if computation.tag_or_branch.present?
          computation.revision = revision
          computation.script = ScriptGenerator.new(computation, template).call
        end
        computation.job_id = nil
        computation.stdout_path = nil
        computation.stderr_path = nil
      end

      def internal_run
        ::Rimrock::StartJob.perform_later computation if computation.valid?
      end

      def template
        @template_fetcher.new(@repository, @file, computation.revision).call
      end

      def revision
        @revision_fetcher.new(@repository, computation.tag_or_branch).call
      end
    end
  end
end
