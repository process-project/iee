# frozen_string_literal: true

module PipelineSteps
  module Scripted
    class CloudRunner < PipelineSteps::RunnerBase
      def initialize(computation, repository, file, options = {})
        super(computation, options)
        @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
        @repository = repository
        @file = file
        @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
        @revision_fetcher = options.fetch(:revision_fetcher) { Gitlab::Revision }
        @atmosphere_client = ::Cloud::Client.new(computation.user.token)
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
          computation.appliance_id = @atmosphere_client.spawn_appliance
          computation.status = 'created'
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
