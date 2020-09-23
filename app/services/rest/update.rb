# frozen_string_literal: true

module Rest
  class Update < Rest::Service
    def initialize(user, options = {})
      super(user)
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
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
      body = parse(response.body)
      job_status = body[:status]
      if %w[queued running finished error failed].include job_status
        message = body[:message]
        job_status = 'error' if job_status == 'failed'
      else
        message = 'Unknown job status received from external server'
        job_status = 'error'
      end
      update_computation(computation, job_status, message)
    end

    def error(computation, response)
      message = if response.body.nil?
                  Rack::Utils::HTTP_STATUS_CODES[response.status]
                else
                  parse(response.body)[:message]
                end
      message ||= 'Unknown external server or connection error'
      update_computation(computation, 'error', message)
    end

    def update_computation(computation, new_status, message)
      return if new_status == computation.status
      ActivityLogWriter.write_message(
        computation.pipeline.user, computation.pipeline, computation,
        "computation_status_change_#{new_status.downcase}"
      )
      computation.update_attributes(status: new_status, error_message: message)
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
