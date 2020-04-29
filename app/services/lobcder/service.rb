# frozen_string_literal: true

require 'faraday'
require 'json'

# TODO: throw exceptions
module Lobcder
  class Service
    def initialize(uc = :uc1)
      @uc = uc
      @connection = get_connection(uc)
    end

    def mkdir(commands)
      # see commands argument example in mkdir_batch
      mkdir_batch(commands)
    end

    def mkdir_single(site_name, path, recursive = true)
      # see commands argument example in mkdir_batch

      commands = [{
        name: site_name.to_s,
        path: path,
        recursive: recursive
      }]

      mkdir_batch commands
    end

    def mkdir_batch(commands)
      # commands argument example
      # [
      #     { "name":"krk", "path":"/some_folder/other_folder" },
      #     { "name":"krk", "path":"/some_folder/another_folder" },
      # ]

      payload = commands.to_json
      response = @connection.post do |req|
        req.url attribute_fetcher('mkdir_path')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end

      response = JSON.parse(response.body, symbolize_names: true)
      response.values.all? { |status| status.eql? 'Ok' }
      unless response.values.all? { |status| status.eql? 'Ok' }
        raise Lobcder::ServiceFailure, 'Not all LOBCDER API remove commands have completed successfully'
      end
    end

    def rm(commands)
      # see commands argument example in rm_batch
      rm_batch(commands)
    end

    def rm_single(site_name, path, recursive = true)
      # see commands argument example in rm_batch

      commands = [{
        name: site_name.to_s,
        file: path,
        recursive: recursive
      }]

      rm_batch commands
    end

    def rm_batch(commands)
      # commands argument example
      # [
      #     { "name":"krk", "path":"/some_folder/other_folder" },
      #     { "name":"krk", "path":"/some_folder/some_file.txt" },
      # ]

      commands.each { |command| command[:recursive] = true }
      # Convert commands' 'path' keys to 'file' - adaptation to LOBCDER API
      commands.each { |command| command[:file] = command.delete :path }
      payload = commands.to_json

      response = @connection.post do |req|
        req.url attribute_fetcher('rm_path')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end

      response = JSON.parse(response.body, symbolize_names: true)
      unless response.values.all? { |status| status.eql? 'Ok' }
        raise Lobcder::ServiceFailure, 'Not all LOBCDER API mkdir commands have completed successfully'
      end
    end

    def folders
      folders_response = @connection.get(attribute_fetcher('folders_path'))
      JSON.parse(folders_response.body, symbolize_names: true)
    end

    def site_root(site_name)
      folders[site_name][:path]
    end

    def site_names
      folders.keys
    end

    def copy(commands)
      # see commands argument example in copy_move_utility
      copy_move_utility(commands, attribute_fetcher('copy_path'))
    end

    def move(commands)
      # see commands argument example in copy_move_utility
      copy_move_utility(commands, attribute_fetcher('move_path'))
    end

    def status(track_id)
      response = @connection.get "#{attribute_fetcher('status_path')}/#{track_id}"
      JSON.parse(response.body, symbolize_names: true)#[:status]
    end

    def list(site_name, path, recursive = false)
      payload = {
        name: site_name.to_s,
        path: path,
        recursive: recursive
      }.to_json

      response = @connection.post do |req|
        req.url attribute_fetcher('list_path')
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
      response = JSON.parse(response.body, symbolize_names: true)
      response - [path, "/#{path}", "/#{path}/", "#{path}/"] # TODO: remove adapter later
    end


    # TODO: implement
    def restart
      payload = {
          name: "#{@uc}-microinfra"
      }
    end

    private

    def get_connection(uc)
      infra_host = attribute_fetcher('infra_host')
      infra_port = attribute_fetcher('infra_port')
      infra_path = attribute_fetcher('infra_path')
      infra_token_header = attribute_fetcher('infra_token_header')
      uc_infra_token = attribute_fetcher("#{uc}_infra_token")

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
      # [
      #     {
      #         :dst=>{:name=>"krk", :path=>"/some_folder_1"},
      #         :src=>{:name=>"krk", :path=>"/some_folder_1/some_file_1.txt"}
      #     },
      #     {
      #         :dst=>{:name=>"krk", :path=>"/some_folder_2"},
      #         :src=>{:name=>"krk", :path=>"/some_folder_2/some_file_2.txt"}
      #     }
      # ]

      # Convert commands' 'path' keys to 'file' - adaptation to LOBCDER API
      commands.each do |command|
        [:dst, :src].each { |key| command[key][:file] = command[key].delete :path }
      end
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

      parsed_response = JSON.parse(response.body, symbolize_names: true)

      {
        status: parsed_response[:status],
        track_id: parsed_response[:trackId]
      }
    end

    def attribute_fetcher(attribute)
      Rails.application.config_for('process')['staging'][attribute]
    end
    # TODO: send proper webhook via LOBCDER API
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
