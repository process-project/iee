# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class CreateDeployment < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      create_deployment if preconditions
    end

    private

    def create_deployment
      body = {
        blueprint_id: cloudify_blueprint
      }

      url, req = create_request(
        :put,
        "#{cloudify_url}/deployments/#{iee_deployment_name}?_include=id",
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

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      Rails.logger.debug("REPLY FROM CLOUDIFY: #{res.body.inspect}")

      # Assume id is name of service that has just been started
      svc_id = res_hash['id']

      Rails.logger.debug("CLOUDIFY DEPLOYMENT NAME: #{svc_id}")

      computation.deployment_name = svc_id
      computation.status = 'running'
      computation.cloudify_status = 'deployment_started'
      computation.save
    end

    def preconditions
      # This action has the following preconditions:
      # - deployment does not yet exist
      computation.cloudify_status == 'not_started' &&
        !Cloudify::CheckDeployment.new(computation).call
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
