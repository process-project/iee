# frozen_string_literal: true

module Rest
  class Update
    def initialize(user, options = {})
      @service_url = 'http://' +
                     Rails.application.config_for('process')['Rest']['host'] + ":" +
                     Rails.application.config_for('process')['Rest']['port']
      @job_status_path = Rails.application.config_for('process')['Rest']['job_status_path']
      @user = user
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
    end

    def call
      active_computations.each do |computation|
        response = connection.get(@job_status_path + "/" + computation.job_id)
        case response.status
        when 200 then success(computation, response.body)
        when 422 then error(response.body, :timeout)
        else error(response.body, :internal)
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

    def success(computation, body)
      parsed_body = JSON.parse(body, symbolize_names: true)
      update_computation(computation, parsed_body[:status], parsed_body[:message])
    end

    def update_computation(computation, status, message)
      new_status = status.downcase

      if new_status != "error"
        current_status = computation.status

        computation.update_attributes(status: new_status)
        on_finish_callback(computation) if computation.status == 'ok'
        update(computation) if current_status != new_status
      else
        computation.update_attributes(status: new_status, error_message: message)
      end
    end

    def error(body, error_type)
      Rails.logger.tagged(self.class.name) do
        Rails.logger.warn(
          I18n.t("rest.#{error_type}", user: @user&.name, details: body)
        )
      end
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
