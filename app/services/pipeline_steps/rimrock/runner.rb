# frozen_string_literal: true

module PipelineSteps
  module Rimrock
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, repo, file, options = {})
        super(computation, options)
        @repo = repo
        @file = file
        @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
        @revision_fetcher = options.fetch(:revision_fetcher) { Gitlab::Revision }
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

      def template
        @template_fetcher.new(@repo, @file, computation.revision).call
      end

      def revision
        @revision_fetcher.new(@repo, computation.tag_or_branch).call
      end
    end
  end
end
