# frozen_string_literal: true

module PipelineSteps
  module Scripted
    class RimrockRunner < PipelineSteps::RunnerBase
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
        computation.revision = revision
        computation.script = ScriptGenerator.new(computation, template).call
        computation.job_id = nil
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
