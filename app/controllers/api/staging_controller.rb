module Api
	class StagingController < Api::ApplicationController
		skip_before_action :authenticate_user!

		before_action :authenticate_staging!

		def notify
			@@my_logger ||= Logger.new("#{Rails.root}/log/debug.log")

			json_content = params[:status]
			@@my_logger.debug("Webhook output: ID=#{json_content["id"]}, status=#{json_content["status"]}")
		end

		private

		def authenticate_staging!
			invalid! unless valid_token?
		end

		def valid_token?
			@@my_logger ||= Logger.new("#{Rails.root}/log/debug.log")
			@@my_logger.debug(" From ENV: #{ENV["STAGING_SECRET"]}")
			ENV["STAGING_SECRET"] && ENV["STAGING_SECRET"] == token
		end

		def token
			@@my_logger ||= Logger.new("#{Rails.root}/log/debug.log")
			@@my_logger.debug("From request's header: #{request.headers["x-staging-token"]}")
			request.headers["x-staging-token"]
		end

		def invalid!
      		head :unauthorized,
      			'WWW-Authenticate' => 'x-staging-token header is invalid'
    	end

	end
end