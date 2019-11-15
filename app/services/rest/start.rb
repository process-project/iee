# frozen_string_literal: true

module Rest
  class Start < Rest::Service
    def initialize(computation)
      super(computation.user)
      @computation = computation
      @logger = Logger.new(Rails.root.join('log', 'alfa.log'))
      @logger.info("lol")

    end

    def call
      response = make_request
      @logger.info("Response for job #{@computation.job_id}...:: #{response.body}")

      # TODO Jasiu response case error, or success
      @computation.update_attributes(status: 'running')
      # end TODO Jasiu response case error, or success
    end

    private

    def make_request
      connection.post do |req|
        req.url submission_path
        req.headers['Content-Type'] = 'application/json'
        req.body = req_body
      end
    end

    # TODO when Robin changes that we get id from him not the other way around
    def submission_path
      Rails.application.config_for('process')['rest']['job_submission_path'] + "/" + @computation.job_id   
    end

    def req_body
      @computation.parameter_values.to_json
    end
  end
end
