# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class CheckExecution < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      check_execution
    end

    private

    def check_execution
      Rails.logger.debug('GETTING STATUS OF EXECUTION')

      if computation.workflow_id.blank?
        Rails.logger.debug('NO WORKFLOW ID SAVED IN COMPUTATION')
        return 'not_started'
      end

      url, req = create_request(
        :get,
        "#{cloudify_url}/executions/#{computation.workflow_id}"
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

      # Look for res_hash['status']
      # Possible states:
      #   pending -- means: setting up
      #   started -- means: computation is running
      #   terminated -- means: computation finished (not sure if successfully)

      status = res_hash['status']
      Rails.logger.debug("EXEC STATUS: #{status}")

      status
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
