module Staging
  require 'faraday'
  require 'securerandom'
  class Service
    def initialize(uc)
      @connection = meta_connection(uc)
    end

    def mkdir(uc, host_alias, path)
    end

    def rm(uc, host_alias, path)
    end

    def host_aliases(uc)
      @connection.get()
      return host_aliases
    end



    def copy(commands)
      copy_move_utility(commands, attribute_fetcher('copy_path'))
    end

    def move(commands)
      copy_move_utility(commands, attribute_fetcher('move_path'))
    end

    def status(track_id)
      response = @connection.get "#{attribute_fetcher('status_path')}/#{track_id}"
      JSON.parse(response.body)['status'] # We don't care about each one file status
    end

    def list(host_alias, path)
      payload = {
          'name': host_alias,
          'path': path
      }.to_json

      response = @connection.post do |req|
        req.url attribute_fetcher('list_path'),
        req.body = payload
      end
      JSON.parse(response.body)
    end

    private

    def endpoint_for(uc)
      [entry_endpoints, ports, token]
    end

    def connection(host, port, token)

    end

    def meta_connection(uc, )
      connection
    end

    # utilities
    def copy_move_utility(commands, api_path)
      # commands argument example
      # [
      #     {
      #         'dst': {
      #             'name': 'lrzcluster',
      #             'file': '/'
      #         },
      #         'src': {
      #             'name': 'krk',
      #             'file': '10M.dat'
      #         }
      #     }
      # ]
      payload = {
          'id': SecureRandom.hex, # what should we send?
          'webhook': webhook_info,
          'cmd': commands
      }.to_json

      response = @connection.post do |req|
        req.url attribute_fetcher(api_path)
        req.body = payload
      end
      JSON.parse(response.body)['trackId']
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