# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class RunUninstallWorkflow < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      run_uninstall_workflow if preconditions
    end

    private

    def run_uninstall_workflow
      Rails.logger.debug('IN CLOUDIFY - RUN UNINSTALL WORKFLOW')

      body = {
        deployment_id: computation.deployment_name,
        workflow_id: 'uninstall'
      }

      Rails.logger.debug('STARTING UNINSTALL WORKFLOW')

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

      computation.workflow_id = exec_id
      computation.status = 'running'
      computation.cloudify_status = 'uninstall_workflow_launched'
      computation.save
    end

    def preconditions
      # This action has the following preconditions:
      # - deployment exists
      # - no workflows are pending
      # - computation state is 'running'

      Cloudify::CheckDeployment.new(computation).call &&
        Cloudify::CheckExecution.new(computation).call == 'terminated' &&
        computation.cloudify_status == 'application_workflow_launched'
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
