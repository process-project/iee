# frozen_string_literal: true

module Lobcder
  class Update
    def initialize(computation, options = {})
      @computation = computation
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
      @service = Service(uc_for(computation))
    end

    def call
      begin
        track_id = @computation.track_id
        status = @service.status(track_id)

        @computation.status == 'finished' if status == 'DONE_ALL'
      rescue Lobcder::Exception
        @computation.status == 'error'
      end

      # Old - bad (tzn by marek xd) implementation
      # return if @computation.nil? # TODO: Why would a computation be nil?
      @on_finish_callback&.new(@computation)&.call # TODO: What does callback and updater do?
      @updater&.new(@computation)&.call
    end

    private

    def uc_for(computation)
      Flow.uc_for(computation.pipeline.flow.to_sym)
    end
  end
end
