# frozen_string_literal: true

module PipelineSteps
  module Cloud
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, repository, file, options = {})
        super(computation, options)
        @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
        @appliance_type_id = 884 # Temporary - cloud pipeline step template v05
        @repository = repository
        @file = file
        @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
        @revision_fetcher = options.fetch(:revision_fetcher) { Gitlab::Revision }
        @atmosphere_client = ::Cloud::Client.new(computation.user.token, @atmosphere_url)
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
          @atmosphere_client.register_initial_config(computation.user.email, computation.script)
          @atmosphere_client.spawn_appliance_set
          @atmosphere_client.spawn_appliance(884) # TODO: parameterize
          computation.status = 'running'
          computation.save
        end
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
