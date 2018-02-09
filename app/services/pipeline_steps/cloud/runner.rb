# frozen_string_literal: true

module PipelineSteps
  module Cloud
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, atmosphere_url, repository, file, options = {})
        super(computation, options)
        @atmosphere_url = atmosphere_url
        @appliance_type_id = 882 # Temporary - cloud pipeline step template v03
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
        if computation.valid?

        end

#        ::Rimrock::StartJob.perform_later computation if computation.valid?
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
