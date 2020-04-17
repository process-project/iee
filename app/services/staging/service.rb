require 'faraday'
require 'json'

module Staging
  class Service
    def initialize(uc_no)
      @connection = get_connection(uc_no)
    end

    # TODO: Not implemented in LOBCDER, assuming that you can mkdir multiple paths
    def mkdir(host_alias, paths)
      mkdir_path = 'TODO' # Doesnt exist yet - not implemented in LOBCDER

      request_body = {
          name: host_alias,
          path: paths
      }

      connection.post do |req| # Only a guess on how could such a request look
        req.url mkdir_path
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body
      end
    end

    # TODO: Not implemented in LOBCDER, assuming that you can rm multiple paths
    def rm(host_alias, paths)
      rm_path = 'TODO' # Doesnt exist yet - not implemented in LOBCDER

      request_body = {
          name: host_alias,
          path: paths
      }

      connection.post do |req| # Only a guess on how could such a request look
        req.url rm_path
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body
      end
    end

    def host_aliases
      folders_path = Rails.application.config_for('process')['staging']['folders_path']

      folders_response = @connection.get(folders_path)
      body = JSON.parse(folders_response.body, symbolize_names: false)

      body.keys
    end

    private

    def get_connection(uc_no)
      infra_host = Rails.application.config_for('process')['staging']['infra_host']
      infra_port = Rails.application.config_for('process')['staging']['infra_port']
      infra_path = Rails.application.config_for('process')['staging']['infra_path']
      infra_token_header = Rails.application.config_for('process')['staging']['infra_token_header']
      uc_infra_token = Rails.application.config_for('process')['staging']["uc#{uc_no}_infra_token"]

      infra_resp = Faraday.get("#{infra_host}:#{infra_port}#{infra_path}") do |req|
        req.headers[infra_token_header] = uc_infra_token
      end

      body = JSON.parse(infra_resp.body, symbolize_names: true)

      scp_service = body[:services].select { |service| service[:type] == 'scp' }.first
      endpoint = "http://#{scp_service[:entryEndpoints].first}"
      endpoint_port = scp_service[:ports].first.to_s

      token = body[:token][:value]
      token_header = body[:token][:header]

      Faraday.new(url: "#{endpoint}:#{endpoint_port}") do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers[token_header] = token
      end
    end
  end
end