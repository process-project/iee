# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class CheckDeployment < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      check_deployment
    end

    private

    def check_deployment
      Rails.logger.debug("CHECKING IF DEPLOYMENT #{iee_deployment_name} EXISTS...")

      url, req = create_request(
        :get,
        "#{cloudify_url}/node-instances?deployment_id=#{iee_deployment_name}"
      )
      res = Net::HTTP.start(
        url.host,
        url.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)
      nodes = res_hash['metadata']['pagination']['total']

      Rails.logger.debug("TOTAL NODES: #{nodes}")

      if nodes.present? && nodes == 2
        Rails.logger.debug('2 NODES DETECTED - DEPLOYMENT EXISTS.')
        return true
      else
        Rails.logger.debug('NO NODES DETECTED - DEPLOYMENT DOES NOT EXIST.')
        return false
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
