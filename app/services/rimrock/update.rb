module Rimrock
  class Update < ProxyService
    def initialize(user, options = {})
      super(user,
            Rails.application.config_for('eurvalve')['rimrock_url'],
            options)

      @user = user
    end

    def call
      if active_computations.size > 0
        response = connection.get('api/jobs')
        case response.status
        when 200 then success(response.body)
        when 422 then error(response.body, :timeout)
        else error(response.body, :internal)
        end
      end
    end

    private

    def success(body)
      json_body = JSON.parse(body)
      statuses = Hash[json_body.map { |e| [e['job_id'], e] }]

      active_computations.each do |computation|
        puts "active: #{computation}"
        new_status = statuses[computation.job_id]
        if new_status
          computation.update_attribute(:status, new_status['status'].downcase)
        else
          computation.update_attributes(
            status: 'error',
            error_message: 'Job cannot be found')
        end
      end
    end

    def error(body, error_type)
      Rails.logger.tagged(self.class.name) do
        Rails.logger.warn(
          I18n.t("rimrock.#{error_type}", user: @user&.name, details: body))
      end
    end

    def active_computations
      @ac ||=
        @user.computations.where(status: ['queued', 'running'])
    end
  end
end
