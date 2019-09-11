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
    end

    def call
      return if active_computations.empty?

      active_computations.each do |computation|
        response = connection.get(@job_status_path + computation.id)
        case response.status
        when 200 then success(response.body)
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

    # TODO: possibly edit when UC5 api is working
    def success(body)
      status = Hash[JSON.parse(body).map { |e| [e['id'], e] }]
      update_computation(computation, status[computation.id])
    end

    # TODO: possibly edit when UC5 api is working
    def update_computation(computation, new_status)
      if new_status
        current_status = computation.status
        updated_status = new_status['status'].downcase

        computation.update_attributes(status: updated_status)
        on_finish_callback(computation) if computation.status == 'finished'
        update(computation) if current_status != updated_status
      else
        computation.update_attributes(status: 'error', error_message: 'Job cannot be found')
      end
    end

    # TODO: possibly edit when UC5 api is working
    def error(body, error_type)
      Rails.logger.tagged(self.class.name) do
        Rails.logger.warn(
          I18n.t("rimrock.#{error_type}", user: @user&.name, details: body)
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
