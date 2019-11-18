# frozen_string_literal: true

module Rest
  class Start < Rest::Service
    def initialize(computation)
      super(computation.user)
      @computation = computation
    end

    def my_logger
      @@my_logger ||= Logger.new(Rails.root.join('log', 'alfa.log'))
    end

    def call
      response = make_request
      case response.status
      when 200 success(response)
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

    # TODO when Robin changes that we get id from him not the other way around
    def submission_path
      Rails.application.config_for('process')['rest']['job_submission_path'] + "/" + @computation.job_id   
    end

    def req_body
      @computation.parameter_values.to_json
    end

    def success(response)
      my_logger.info("success")
      my_logger.info("Response.status: #{response.status}")
      my_logger.info("Response.body: #{response.body}")

      body = JSON.parse(response.body, symbolize_names: true)
      job_status = body[:status]
      # TODO: maybe some handling of message in non-error case body[:message]

      my_logger.info("job_status: #{job_status}")

      @computation.update_attributes(status: job_status)
    end

    def error(response)
      my_logger.info("error")
      my_logger.info("Response.status: #{response.status}")
      my_logger.info("Response.body: #{response.body}")

      if not response.body.nil?
        body = JSON.parse(response.body, symbolize_names: true)
        message = body[:message]
      end
      message ||= "Unknown error"
      @computation.update_attributes(status: "error",
                                     error_message: message)

      my_logger.info("message: #{message}")
    end
  end
end
