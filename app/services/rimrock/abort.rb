# frozen_string_literal: true

module Rimrock
  class Abort < Rimrock::Service
    def initialize(computation, updater, options = {})
      super(computation, options)
      @updater = updater
      @msg = options.fetch(:msg, 'Job aborted')
    end

    def call
      return until computation.active?

      abort_job! if proxy_valid?
      computation.update(status: :aborted, error_message: @msg)
      @updater.new(computation).call
    end

    private

    def abort_job!
      connection.put do |req|
        req.url "api/jobs/#{computation.job_id}"
        req.headers['Content-Type'] = 'application/json'
        req.body = { action: :abort }.to_json
      end
    end

    def proxy_valid?
      Proxy.new(user).valid?
    end
  end
end
