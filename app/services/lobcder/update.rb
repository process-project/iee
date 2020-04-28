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
      if @computation.step.class.name != 'DirectoryBuilderStep'
        begin
          track_id = @computation.track_id
          puts("================================================= BEFORE STATUS: #{@computation.status} ==============================================================================")

          puts("================================================= TRACK ID: #{track_id} ==============================================================================")

          status = @service.status(track_id)
          puts("================================================= NEW STATUS: #{status} ==============================================================================")

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
