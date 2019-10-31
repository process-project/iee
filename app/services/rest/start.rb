# frozen_string_literal: true

module Rest
  class Start < Rest::Service
    def initialize(computation)
      super(computation.user)
      @computation = computation
      @logger = Logger.new(Rails.root.join('log', 'alfa.log'))
      @logger.info("Inside Rest::Start init")
    end

    # Raises an HTTP error if the response is not 200 -> TODO change status to error
    def call
      response = make_request
      @logger.info("Request made man...:: #{response.body}")
      @computation.update_attributes(status: 'running')
    end

    private

    def make_request
      @logger.info("Inside Rest::Start make_request")
      connection.post do |req|
        req.url service_path
        @logger.info("after service_path inside make Request")
        req.headers['content-type'] = 'application/json'
        req.body = request_body
      end
    end

    def service_path
      Rails.application.config_for('process')['rest']['job_submission_path'] + "/" + @computation.job_id    
    end

    def request_body
      @computation.parameter_values.to_json
    end
  end
end
