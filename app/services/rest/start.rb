# frozen_string_literal: true

module Rest
  require 'net/http'
  require 'json'

  class Start
    def initialize(computation)
      @computation = computation
    end

    # Raises an HTTP error if the response is not 200 -> TODO change status to error
    def call
      response = make_request.value 
      @computation.update_attributes(status: 'running', job_id: @computation.id)
    end

    private

    def make_request
      http = Net::HTTP.new(service_host, service_port)
      req = Net::HTTP::Post.new(service_path, 'content-type' => 'application/json',
                                              'authorization: bearer' => @computation.user.token)
      req.body = request_body
      http.request(req)
    end

    def service_host
      Rails.application.config_for('process')['rest']['host']
    end

    def service_port
      Rails.application.config_for('process')['rest']['port']
    end

    def service_path
      Rails.application.config_for('process')['Rest']['job_submission_path'] + @computation.id
    end

    def request_body
      @computation.parameter_values
    end
  end
end
