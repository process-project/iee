# frozen_string_literal: true

module Rest
  class Start < Rest::Service
    def initialize(computation)
      super(computation.user)
      @computation = computation
    end

    def call
      response = make_request
      case response.status
      when 200 then success(response)
      else error(response)
      end
    end

    private

    def make_request
      connection.post do |req|
        req.url submission_path
        req.headers['Content-Type'] = 'application/json'
        req.body = req_body
      end
    end

    def submission_path
      Rails.application.config_for('process')['rest']['job_submission_path']
    end

    def req_body
      @computation.parameter_values.to_json
    end

    def success(response)
      body = JSON.parse(response.body, symbolize_names: true)
      job_status = body[:status] # TODO: Do something with the message if needed
      job_id = body[:message]
      @computation.update_attributes(status: job_status, job_id: job_id)
    end

    def error(response)
      unless response.body.nil?
        body = JSON.parse(response.body, symbolize_names: true)
        message = body[:message]
      end

      message ||= 'Unknown error'
      @computation.update_attributes(status: 'error',
                                     error_message: message)
    end
  end
end
