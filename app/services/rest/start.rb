# frozen_string_literal: true

module Rest
  class Start < Rest::Service
    def initialize(computation)
      super(computation.user)
      @computation = computation
    end

    # Raises an HTTP error if the response is not 200 -> TODO change status to error
    def call
      response = make_request
      # TODO response case error 
      @logger.info("Response for job #{@connection.job_id}...:: #{response.body}")
      @computation.update_attributes(status: 'running')
    end

    private

    def make_request
      connection.post do |req|
        req.url submission_path
        req.headers['Content-Type'] = 'application/json'
        req.body = req_body
      end
    end

    # TODO when Robin changes that we get id from him
    def submission_path
      Rails.application.config_for('process')['rest']['job_submission_path'] + "/" + @computation.job_id   
    end

    def req_body
      @computation.parameter_values.to_json
    end
  end
end
