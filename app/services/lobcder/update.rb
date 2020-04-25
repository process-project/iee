# frozen_string_literal: true

module Lobcder
  class Update
    def initialize(computation, options = {})
      @computation = computation
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]

    end

    # TODO: implement service.status(track_id)
    def call
      uc_no = @computation.pipeline.uc_no
      service = Lobcder::Service.new(uc_no)

      begin # TODO: catch LOBCDER EPIC FAILURE
        track_id = @computation.track_id
        status = status_parser(service.status(track_id))
        update_status(status)
      rescue
        update_status(:error)
      ensure


      # Old - bad(tzn by marek xd)implementation
      return if @computation.nil? # TODO: Why would a computation be nil?
      @on_finish_callback&.new(@computation)&.call # TODO: What does callback and updater do?
      @updater&.new(@computation)&.call
    end

    private

    def status_parser(lobcder_status)
      # TODO: implement
    end

    def update_status(status)
      # TODO: implement
    end
  end
end
