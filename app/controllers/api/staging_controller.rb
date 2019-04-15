# frozen_string_literal: true

module Api
  class StagingController < Api::ApplicationController
    skip_before_action :authenticate_user!

    before_action :authenticate_staging!

    # rubocop:disable Metrics/MethodLength
    def notify
      computation_id = params[:status][:id]
      @computation = Computation.find computation_id
      if @computation.nil?
        Rails.logger.error('Invalid id in LOBCDER API response ' \
                           "in StagingControler#notify: #{computation_id}")
        return
      end

      status = params[:status][:status]
      if status == 'done'
        @computation.update_attributes(status: 'finished')
      else
        @computation.update_attributes(status: 'error')
      end

      StagingIn::UpdateJob.perform_later(@computation)
    end
    # rubocop:enable Metrics/MethodLength

    private

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
