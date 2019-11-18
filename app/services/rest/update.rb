# frozen_string_literal: true

module Rest
  class Update
    def initialize(user, options = {})
      @service_url = 'http://' +
                     Rails.application.config_for('process')['Rest']['host'] +
                     Rails.application.config_for('process')['Rest']['port']
      @job_status_path = Rails.application.config_for('process')['Rest']['job_status_path']
      @user = user
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
      @logger = Loggger.new("log/alfa")
    end

    def my_logger
      @@my_logger ||= Logger.new("#{Rails.root}/log/alfa.log")
    end

    def call
      return if active_computations.empty?

      active_computations.each do |computation|
        response = connection.get(@job_status_path + computation.id)
        http_status = response.status
        if http_status == 200
          body = JSON.parse(response.body)
          job_status = body["status"]
          message = body["message"]
        else          
          my_logger.info("Bad response")
          my_logger.info("Response status: #{response.status}")
          my_logger.info("Response body: #{response.body}")

          body = JSON.parse(response.body)
          job_status = body["status"]
          message = body["message"]
          my_logger.info("job_status: #{job_status}")
          my_logger.info("message: #{message}")
        end
      end
    end

    private

    def connection
      @connection ||= Faraday.new(url: @service_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['authorization: bearer'] = @user.token
      end
    end

    def update_computation(computation, new_status, message)
      return if new_status == computation.status
      if new_status == "error"
        computation.update_attributes(status: new_status, error_message: message)
      else
        computation.update_attributes(status: new_status)
      end
      on_finish_callback(computation) if computation.status == 'finished'
      update(computation)
    end

    def active_computations
      @ac ||= @user.computations.submitted_rest
    end

    def on_finish_callback(computation)
      @on_finish_callback&.new(computation)&.call
    end

    def update(computation)
      @updater&.new(computation)&.call
    end
  end
end
