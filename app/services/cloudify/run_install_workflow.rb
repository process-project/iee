# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class RunInstallWorkflow < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      run_install_workflow if preconditions
    end

    private

    def run_install_workflow
      Rails.logger.debug('IN CLOUDIFY - RUN INSTALL WORKFLOW')

      body = {
        deployment_id: computation.deployment_name,
        workflow_id: 'install'
      }

      Rails.logger.debug('STARTING INSTALL WORKFLOW')

      url, req = create_request(:post, "#{cloudify_url}/executions", body)
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

      Rails.logger.debug("REPLY FROM CLOUDIFY (EXEC ID): #{exec_id}")

      computation.workflow_id = exec_id
      computation.status = 'running'
      computation.cloudify_status = 'install_workflow_launched'
      computation.save
    end

    def preconditions
      # This action has the following preconditions:
      # - deployment exists
      # - no workflow has yet been launched
      # - computation state is 'new'

      Cloudify::CheckDeployment.new(computation).call &&
        Cloudify::CheckExecution.new(computation).call == 'not_started' &&
        computation.cloudify_status == 'deployment_started'
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
