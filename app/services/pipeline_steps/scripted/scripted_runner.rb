# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

module PipelineSteps
  module Scripted
    class ScriptedRunner < PipelineSteps::Scripted::ScriptedRunnerBase
      protected

      def internal_run
        case computation.deployment
        when 'cluster'
          ::Rimrock::StartJob.perform_later computation if computation.valid?
        when 'cloud'
          @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
          @atmosphere_client = ::Cloud::Client.new(computation.user.token)
          @atmosphere_client.spawn_appliance_set
          computation.appliance_id = @atmosphere_client.spawn_appliance(
            computation.user.email, computation.script
          )
          computation.status = 'queued'
          computation.save
        end
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
