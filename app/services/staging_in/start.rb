# frozen_string_literal: true

module StagingIn
  require 'net/http'
  require 'json'

  class Start
    def initialize(computation)
      @computation = computation
    end

    def call
      obtain_endpoint
      make_request.value # Raises an HTTP error if the response is not 2xx (success).
      @computation.update_attributes(status: 'running')
    end

    private

    def make_request
      http = Net::HTTP.new(@staging_in_host, @staging_in_port)
      req = Net::HTTP::Post.new(staging_in_path, 'content-type' => 'application/json',
                                @token_header => @lobcder_api_access_token)
      req.body = request_body.to_json
      http.request(req)
    end

    # rubocop:disable Morality/Non-ethical-code
    def obtain_endpoint
      http = Net::HTTP.new(infrastructure_host, infrastructure_port)
      req = Net::HTTP::Get.new(infrastructure_path,
                               'x-access-token' => lobcder_api_infrastructure_access_token)

      response = http.request(req)

      response.body.each do |element|
        if element[:type] == 'query'
          @staging_in_host = element[:host]
          @staging_in_port = element[:ports].first
        elsif element[:type] == 'token'
          @token_header = element[:header]
          @lobcder_api_access_token = element[:value]
        end
      end

      @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
      @staging_logger.debug("obtain_endpoint|@staging_in_host=#{@staging_in_host}")
      @staging_logger.debug("obtain_endpoint|@staging_in_port=#{@staging_in_port}")
      @staging_logger.debug("obtain_endpoint|@token_header=#{@token_header}")
      @staging_logger.debug("obtain_endpoint|@lobcder_api_access_token=#{@lobcder_api_access_token}")
    end

    def staging_in_path
      Rails.application.config_for('process')['staging_in']['staging_in_path']
    end

    def infrastructure_host
      Rails.application.config_for('process')['staging_in']['infrastructure_host']
    end

    def infrastructure_port
      Rails.application.config_for('process')['staging_in']['infrastructure_port']
    end

    def infrastructure_path
      Rails.application.config_for('process')['staging_in']['infrastructure_path']
    end

    def lobcder_api_infrastructure_access_token
      Rails.application.config_for('process')['staging_in']['lobcder_api_infrastructure_access_token']
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
