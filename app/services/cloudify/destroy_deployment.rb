# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class DestroyDeployment < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      destroy_deployment if preconditions
    end

    private

    def destroy_deployment
      body = {
        blueprint_id: cloudify_blueprint
      }

      url, req = create_request(
        :delete,
        "#{cloudify_url}/deployments/#{computation.deployment_name}",
        body
      )

      Rails.logger.debug("DISPATCHING REQUEST TO CLOUDIFY: #{req.inspect}")

      res = Net::HTTP.start(
        url.host,
        url.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        http.request(req)
      end

      # Obtain ID from body
      Rails.logger.debug("REPLY FROM CLOUDIFY: #{res.body.inspect}")

      computation.deployment_name = ''
      computation.status = 'finished'
      computation.cloudify_status = 'deployment_destroyed'
      computation.save
    end

    def preconditions
      # This action has the following preconditions:
      # - deployment exists
      # - computation state is 'finished'

      Cloudify::CheckDeployment.new(computation).call &&
        Cloudify::CheckExecution.new(computation).call == 'terminated' &&
        computation.cloudify_status == 'uninstall_workflow_launched'
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
