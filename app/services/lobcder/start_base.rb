module Lobcder
  class StartBase
    def initialize(computation)
      @computation = computation
      @uc_no = computation.uc_no #TODO: imeplement uc_no
      @pipeline_hash = computation.pipeline.hash # TODO: id maybe? or implement hash
    end
  end


  protected

  def move(cmds)
      service = Lobcder::Service.new(@uc_no)

      begin
        track_id = service.move(cmds) # TODO: move of copy?
        update_status("queued? ") # TODO: get status from response
        @computation.track_id = track_id
      rescue LOBCDER_FAILURE
        # TODO: handle error
        update_status("error")
      ensure
      end
  end
end