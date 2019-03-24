# frozen_string_literal: true

module StagingIn
  require 'net/http'
  require 'json'

  class Start
    def initialize(computation)
      @computation = computation
    end

    def call
      @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
      @staging_logger.debug("StagingIn::Start.call also is working")

      make_request.value # Raises an HTTP error if the response is not 2xx (success).
      @computation.update_attributes(status: 'running')
    end

    private

    def make_request
      http = Net::HTTP.new(staging_in_host, staging_in_port)
      # http.use_ssl = true
      req = Net::HTTP::Post.new(staging_in_path, { 'content-type' => 'application/json',
                                'x-access-token' => lobcder_api_access_token })

      req.body = request_body.to_json
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
      # Rails.application.config_for('process')['staging_in']['lobcder_api_access_token']
      # Workaround due to the need of process-dev restarting after .env changing
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAcHJvY2Vzcy1wcm9qZWN0LmV1IiwiaWF0IjoxNTUxMjg0MjEwfQ.gm8iW_Afa2ki5oWPv9y8NXKnmrRKKGkbEJZk7c9NHdhRDJtfEt1uFWgtDCWaUpJ3FbQfPeLhyDgf6vGn_OHoKQpodmGvBhRH2SJTtkDwBEKXqA4WC78Mkuwxylf0VCcqoaw0qYMmn1VGPBC69XUNZH8AERZIhhbTz2wHYY1ku27wDgTrCfTfqYNrTqbMSDefFaZVCi6AusleGTkX6EaLPY_X4hw79xLb3kZyJODfLpEJ0kGOxa3ao3nAmYzsG4jmHAaocvLcKLGe4PMMWLPmoOfFsUcFyT02Ly0Ry2Jmj7ZVEWxNmCpEvMSMebsDDGKf8Ka7GFz7DZuXd89fwL02lQ'
    end

    def request_body
      [{
        id: @computation.id,
        cmd: {
          type: "copy",
          subtype: "scp2scp",
          src: {
            type: "scp",
            host: @computation.src_host,
            user: "di39nox",
            path: @computation.src_path
            },
            dst:{
              type: "scp",
              host: @computation.dest_host,
              user: "plgcushing",
              path: @computation.dest_path
            },
            webhook: {
              method: "POST",
              url: webhook_url,
              headers: { "x-access-token" => staging_secret }
            },
            options: {}
          }
      }]
    end

    def webhook_url
      Rails.application.routes.url_helpers.api_staging_url(protocol: 'https',
                                                           host: ENV['HOST'])
    end

    def staging_secret
      Rails.application.config_for('process')['staging_in']['staging_secret']
    end
  end
end
