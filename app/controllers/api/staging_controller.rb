# frozen_string_literal: true

module Api
  class StagingController < Api::ApplicationController
    skip_before_action :authenticate_user!

    before_action :authenticate_staging!

    def notify
      id = params[:status][:id]
      @computation = Computation.find id
      status = params[:status][:status]
      if status == 'done'
        @computation.update_attributes(status: 'finished')
      else
        @computation.update_attributes(status: 'error')
      end

      @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
      @staging_logger.debug("Webhook request params: #{params}")

      StagingIn::UpdateJob.perform_later(@computation)

      tmp_output_files = @computation.step.tmp_output_files

      pipeline = @computation.pipeline

      project = pipeline.project

      tmp_output_files.each do |file|
        DataFile.create!(project: project,
                         output_of: pipeline,
                         input_of: pipeline,
                         name: file,
                         data_type: :generic_type)
      end
    end

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
