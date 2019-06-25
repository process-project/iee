# frozen_string_literal: true

module Api
  class StagingController < Api::ApplicationController
    skip_before_action :authenticate_user!

    before_action :authenticate_staging!

    # rubocop:disable Metrics/MethodLength
    def notify
      computation_id = params.dig(:status, :id)
      @computation = Computation.find computation_id

      status = params.dig(:status, :status)

      if status == 'done'
        @computation.update_attributes(status: 'finished')
        
        # Workaround for the ordrer of computatations to be right
        # To be deleted when proper directory structure is implemented
        make_tmp_output_file
      else
        @computation.update_attributes(status: 'error')
      end

      StagingIn::UpdateJob.perform_later(@computation)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error('Invalid id in LOBCDER API response ' \
                           "in StagingControler#notify: #{computation_id}")
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

    def make_tmp_output_file
      DataFile.create(name: @computation.tmp_output_file,
                      data_type: :generic_type,
                      project: @computation.pipeline.project,
                      input_of: @computation.pipeline,
                      output_of: @computation.pipeline)

      ComputationUpdater.new(@computation).call
    end
  end
end
