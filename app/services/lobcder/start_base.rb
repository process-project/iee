module Lobcder
  class StartBase
    def initialize(computation)
      @computation = computation
      @service = Service.new(uc_for(computation))
      @pipeline_hash = computation.pipeline.name # TODO: id maybe? or implement hash
    end

    protected

    def move(cmds)
      begin
        track_id = @service.move(cmds) # TODO: move of copy?
        update_status("queued? ") # TODO: get status from response
        @computation.track_id = track_id
      rescue LOBCDER_FAILURE
        # TODO: handle error
        update_status("error")
      ensure
      end
    end

    def rm(cmds)
      begin
        @service.rm(cmds)
      rescue LOBCDER_FAILURE
      ensure
      end
    end

    private

    def uc_for(computation)
      Flow.uc_for(computation.pipeline.flow.to_sym)
    end
  end

  class Exception < RuntimeError
  end
end