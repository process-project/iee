# frozen_string_literal: true

module Api
  class StagingController < Api::ApplicationController
    skip_before_action :authenticate_user!

    before_action :authenticate_staging!

    def notify
      id = params[:status][:id]
      status = params[:status][:status]
      copying_start_timestamp = params[:details][:timestamp]
      copying_elapsed_time = params[:details][:time]
      log(id, status, copying_start_timestamp,
          copying_elapsed_time)

      # TODO: Update record in database
    end

    private

    # to delete, this method has been introduced due to rubocop madness
    def log(id, status, copying_start_timestamp,
            copying_elapsed_time)
      @my_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
      @my_logger.debug("Webhook info: id=#{id}, status=#{status}, " \
                       "copying_start_timestamp=#{copying_start_timestamp}, " \
                       "copying_elapsed_time=#{copying_elapsed_time}")
    end

    def authenticate_staging!
      invalid! unless valid_token?
    end

    def valid_token?
      ENV['STAGING_SECRET'] && ENV['STAGING_SECRET'] == token
    end

    def token
      request.headers['x-staging-token']
    end

    def invalid!
      head :unauthorized,
           'WWW-Authenticate' => 'x-staging-token header is invalid'
    end
  end
end
