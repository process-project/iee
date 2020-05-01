# frozen_string_literal: true

module Lobcder
  class Update
    def initialize(computation, options = {})
      @computation = computation
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
      @service = Service.new(computation.uc)
    end

    def call
      unless @computation.track_id.nil?
        begin
          track_id = @computation.track_id
          status = @service.status(track_id)

          # TODO: Status parsing -> pretty json
          status = status.split(';')[0].strip

          # TODO: handle 'running' LOBCDER STEJTUS
          @computation.update_attributes(status: 'finished') if status == 'DONE_ALL'
        rescue ServiceFailure
          @computation.update_attributes(status: 'error')
        end
      end

      # Old - bad (tzn by marek xd) implementation
      # return if @computation.nil? # TODO: Why would a computation be nil?
      @on_finish_callback&.new(@computation)&.call # TODO: What does callback and updater do?
      @updater&.new(@computation)&.call
    end
  end
end
