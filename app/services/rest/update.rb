# frozen_string_literal: true

module Rest
  class Update < Rest::Service
    def initialize(user, options = {})
      super(user)
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
    end

    def my_logger
      @@my_logger ||= Logger.new(Rails.root.join('log', 'alfa.log'))
    end

    def call
      active_computations.each do |computation|
        response = make_request(computation)
        case response.status
        when 200 then success(computation, response)
        else error(computation, response)
        end
      end
    end

    private

    def active_computations
      @ac ||= @user.computations.created_or_submitted_rest
    end

    def make_request(computation)
      connection.get job_status_path(computation)
    end

    def job_status_path(computation)
      Rails.application.config_for('process')['rest']['job_status_path'] + computation.job_id   
    end

    def success(computation, response)
      my_logger.info("update job success")
      my_logger.info("response.status: #{response.status}")
      my_logger.info("response.body: #{response.body}")

      body = JSON.parse(response.body, symbolize_names: true)
      job_status = body[:status]
      message = body[:message] # TODO Do something with a message

      my_logger.info("job_status: #{job_status}")
      my_logger.info("message: #{message}")

      update_computation(computation, job_status)
    end

    def error(computation, response)
      my_logger.info("error")
      my_logger.info("Response.status: #{response.status}")
      my_logger.info("Response.body: #{response.body}")

      unless response.body.nil?
        body = JSON.parse(response.body, symbolize_names: true)
        message = body[:message]
      end

      message ||= 'Unknown error'

      my_logger.info("message: #{message}")

      update_computation(computation, "error", message)
    end

    def update_computation(computation, new_status, message = nil)
      return if new_status == computation.status
      if new_status == 'error'
        computation.update_attributes(status: new_status, error_message: message)
      else
        computation.update_attributes(status: new_status)
        # TODO: maybe some handling of message in non-error case
      end
      on_finish_callback(computation) if computation.status == 'finished'
      update(computation)
    end

    def on_finish_callback(computation)
      @on_finish_callback&.new(computation)&.call
    end

    def update(computation)
      @updater&.new(computation)&.call
    end
  end
end
