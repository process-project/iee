# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class RunApplicationWorkflow < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      run_application_workflow if preconditions
    end

    private

    def run_application_workflow
      Rails.logger.debug('IN CLOUDIFY - RUN APPLICATION WORKFLOW')

      # body = {
      #   deployment_id: computation.deployment_name,
      #   workflow_id: app_workflow_name
      # }

      # PLACEHOLDER - PLACEHOLDER - PLACEHOLDER
      body = {
        deployment_id: computation.deployment_name,
        workflow_id: 'execute_operation',
        parameters: {
          operation: 'exec',
          node_ids: 'compute_server',
          operation_kwargs: {
            cmd: 'echo',
            arg1: 'Piotr'
          }
        }
      }

      Rails.logger.debug('STARTING APPLICATION WORKFLOW')

      url, req = create_request(
        :post,
        "#{cloudify_url}/executions",
        body
      )
      res = Net::HTTP.start(
        url.host,
        url.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        http.request(req)
      end

      Rails.logger.debug("REPLY FROM CLOUDIFY: #{res.body.inspect}")

      res_hash = JSON.parse(res.body)

      exec_id = res_hash['id']
      if exec_id.present?
        computation.workflow_id = exec_id
        computation.status = 'running'
        computation.cloudify_status = 'application_workflow_launched'
        computation.save
      end
    end

    def preconditions
      # This action has the following preconditions:
      # - deployment exists
      # - no workflows are pending
      # - computation state is 'queued'

      Cloudify::CheckDeployment.new(computation).call &&
        Cloudify::CheckExecution.new(computation).call == 'terminated' &&
        computation.cloudify_status == 'install_workflow_launched'
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
