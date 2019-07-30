# frozen_string_literal: true

module REST
  require 'net/http'
  require 'json'

  class Start
    def initialize(computation)
      @computation = computation
    end

    def call
      response = make_request.value # Raises an HTTP error if the response is not 2xx (success).
      @computation.update_attributes(status: 'running', job_id: get_job_id(response))
    end

    private

    def make_request
      http = Net::HTTP.new(service_host, service_port)
      req = Net::HTTP::Post.new(service_path, 'content-type' => 'application/json',
                                              'Authorization' => computation.user.token)
      req.body = request_body.to_json
      http.request(req)
    end

    def service_host
      Rails.application.config_for('process')['REST']['host']
    end

    def service_port
      Rails.application.config_for('process')['REST']['port']
    end

    def service_path
      Rails.application.config_for('process')['REST']['job_submission_path']
    end

    def request_body
      { parameters: computation.parameter_values }
    end

    def get_job_id(response)
      JSON.parse(response.body)['job_id']
    end
  end
end
