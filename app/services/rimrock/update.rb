# frozen_string_literal: true

module Rimrock
  class Update < ProxyService
    def initialize(user, options = {})
      super(user,
            Rails.application.config_for('eurvalve')['rimrock']['url'],
            options)

      @user = user
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
    end

    def call
      return if active_computations.empty?

      response = connection.get('api/jobs', tag: tag)
      case response.status
      when 200 then success(response.body)
      when 422 then error(response.body, :timeout)
      else error(response.body, :internal)
      end
    end

    private

    def tag
      Rails.application.config_for('eurvalve')['rimrock']['tag']
    end

    def success(body)
      statuses = Hash[JSON.parse(body).map { |e| [e['job_id'], e] }]

      active_computations.each do |computation|
        update_computation(computation, statuses[computation.job_id])
      end
    end

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

    def error(body, error_type)
      Rails.logger.tagged(self.class.name) do
        Rails.logger.warn(
          I18n.t("rimrock.#{error_type}", user: @user&.name, details: body)
        )
      end
    end

    def active_computations
      @ac ||= @user.computations.submitted_rimrock
    end

    def on_finish_callback(computation)
      @on_finish_callback.new(computation).call if @on_finish_callback
    end

    def update(computation)
      @updater.new(computation).call if @updater
    end
  end
end
