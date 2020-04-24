# frozen_string_literal: true

require 'faraday'
require 'json'

module Lobcder
  class Service
    def initialize(uc_no = 1)
      @connection = get_connection(uc_no)
    end

    def mkdir(host_alias, path)
      payload = {
        name: host_alias.to_s,
        path: path
      }.to_json

      @connection.post do |req|
        req.url attribute_fetcher('mkdir_path')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
    end

    def rm(host_alias, path)
      payload = {
        name: host_alias.to_s,
        file: path,
        recursive: true
      }.to_json

      @connection.post do |req|
        req.url attribute_fetcher('rm_path')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
    end

    def folders
      folders_response = @connection.get(attribute_fetcher('folders_path'))
      JSON.parse(folders_response.body, symbolize_names: true)
    end

    def host_aliases
      folders.keys
    end

    def copy(commands)
      copy_move_utility(commands, attribute_fetcher('copy_path'))
    end

    def move(commands)
      copy_move_utility(commands, attribute_fetcher('move_path'))
    end

    def status(track_id)
      response = @connection.get "#{attribute_fetcher('status_path')}/#{track_id}"
      JSON.parse(response.body, symbolize_names: true)[:status]
    end

    def list(host_alias, path, recursive = false)
      payload = {
        name: host_alias.to_s,
        path: path,
        recursive: recursive
      }.to_json

      response = @connection.post do |req|
        req.url attribute_fetcher('list_path')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
      JSON.parse(response.body, symbolize_names: true)
    end

    private

    def get_connection(uc_no)
      infra_host = attribute_fetcher('infra_host')
      infra_port = attribute_fetcher('infra_port')
      infra_path = attribute_fetcher('infra_path')
      infra_token_header = attribute_fetcher('infra_token_header')
      uc_infra_token = attribute_fetcher("uc#{uc_no}_infra_token")

      infra_resp = Faraday.get("#{infra_host}:#{infra_port}#{infra_path}") do |req|
        req.headers[infra_token_header] = uc_infra_token
      end

      body = JSON.parse(infra_resp.body, symbolize_names: true)

      # TODO: make sure this is the only good service
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

    # utilities
    def copy_move_utility(commands, api_path)
      # commands argument example
      # [{:dst=>{:name=>"krk", :file=>"/copy_test4"}, :src=>{:name=>"krk", :file=>"/copy_test3/cp_test_file.txt"}}]
      payload = {
        id: SecureRandom.hex, # what should we send?
        webhook: webhook_info,
        cmd: commands
      }.to_json

      response = @connection.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.url api_path
        req.body = payload
      end

      JSON.parse(response.body, symbolize_names: true)[:trackId]
    end

    def attribute_fetcher(attribute)
      Rails.application.config_for('process')['staging'][attribute]
    end

    def webhook_info
      { method: 'POST',
        url: webhook_url,
        headers: { 'x-staging-token': attribute_fetcher('staging_secret'),
                   'content-type': 'application/json' } }
    end

    def webhook_url
      Rails.application.routes.url_helpers.api_staging_url(protocol: 'https',
                                                           host: ENV['HOST'])
    end
  end
end