# frozen_string_literal: true

module PipelineSteps
  module Scripted
    class CloudRunner < PipelineSteps::Scripted::ScriptedRunnerBase
      def initialize(computation, repository, file, options = {})
        super(computation, repository, file, options)
        @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
        @repository = repository
        @file = file
        @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
        @revision_fetcher = options.fetch(:revision_fetcher) { Gitlab::Revision }
        @atmosphere_client = ::Cloud::Client.new(computation.user.token)
      end

      protected

      def internal_run
        if computation.valid?
          @atmosphere_client.register_initial_config(computation.user.email, computation.script)
          @atmosphere_client.spawn_appliance_set
          computation.appliance_id = @atmosphere_client.spawn_appliance
          computation.status = 'queued'
          computation.save
        end
      end
    end
  end
end
