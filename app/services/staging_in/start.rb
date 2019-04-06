# frozen_string_literal: true

module StagingIn
  require 'net/http'
  require 'json'

  class Start
    def initialize(computation)
      @computation = computation
    end

    def call
      make_request.value # Raises an HTTP error if the response is not 2xx (success).
      @computation.update_attributes(status: 'running')
    end

    private

    def make_request
      http = Net::HTTP.new(staging_in_host, staging_in_port)
      req = Net::HTTP::Post.new(staging_in_path, 'content-type' => 'application/json',
                                                 'x-access-token' => lobcder_api_access_token)
      req.body = request_body.to_json

      @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
      @staging_logger.debug("Staging request req_body: #{req.body}")

      http.request(req)
    end

    def staging_in_host
      Rails.application.config_for('process')['staging_in']['host']
    end

    def staging_in_port
      Rails.application.config_for('process')['staging_in']['port']
    end

    def staging_in_path
      Rails.application.config_for('process')['staging_in']['path']
    end

    def lobcder_api_access_token
      Rails.application.config_for('process')['staging_in']['lobcder_api_access_token']
    end

    # rubocop:disable Metrics/MethodLength
    def request_body
      [{ id: @computation.id,
         cmd: { type: 'copy',
                subtype: 'scp2scp',
                src: { type: 'scp',
                       host: @computation.src_host,
                       user: 'di39nox',
                       path: @computation.src_path },
                dst: { type: 'scp',
                       host: @computation.dest_host,
                       user: 'plgcushing',
                       path: @computation.dest_path },
                webhook: { method: 'POST',
                           url: webhook_url,
                           headers: { 'x-access-token' => staging_secret } },
                options: {} } }]
    end
    # rubocop:enable Metrics/MethodLength

    def webhook_url
      Rails.application.routes.url_helpers.api_staging_url(protocol: 'https',
                                                           host: ENV['HOST'])
    end

    def staging_secret
      Rails.application.config_for('process')['staging_in']['staging_secret']
    end
  end
end
