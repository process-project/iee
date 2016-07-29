# frozen_string_literal: true
module Rimrock
  class Update < ProxyService
    def initialize(user, options = {})
      super(user,
            Rails.application.config_for('eurvalve')['rimrock']['url'],
            options)

      @user = user
      @on_finish_callback = options[:on_finish_callback]
    end

    def call
      unless active_computations.empty?
        response = connection.get('api/jobs', tag: tag)
        case response.status
        when 200 then success(response.body)
        when 422 then error(response.body, :timeout)
        else error(response.body, :internal)
        end
      end
    end

    private

    def tag
      Rails.application.config_for('eurvalve')['rimrock']['tag']
    end

    def success(body)
      json_body = JSON.parse(body)
      statuses = Hash[json_body.map { |e| [e['job_id'], e] }]

      active_computations.each do |computation|
        new_status = statuses[computation.job_id]
        if new_status
          computation.update_attribute(:status, new_status['status'].downcase)
          on_finish_callback(computation) if computation.status == 'finished'
        else
          computation.update_attributes(
            status: 'error',
            error_message: 'Job cannot be found'
          )
        end
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
      @ac ||= @user.computations.where(status: %w(queued running))
    end

    def on_finish_callback(computation)
      @on_finish_callback.new(computation).call if @on_finish_callback
    end
  end
end
