module Lobcder
  class ImplicitStagingStart < StartBase
    def initialize(computation)
      super(computation)
    end

    def call
      # TODO: consistent compute site naming convention
      prev_compute_site = @computation.prev_computation.hpc # TODO: imeplemet next, prev computation
      next_compute_site = @computation.next_computation.hpc # TODO: assuming next/prev steps are SINGULARITY STEPS

      cmds = create_commands(service, prev_compute_site, next_compute_site)

      move(cmds)
    end

    private

    def create_commands(service, prev_compute_site, next_compute_site)
      files = service.list(prev_compute_site, "/pipelines/#{@pipeline_hash}/out")
      # TODO: moving folders works?
      cmds = []

      files.each do |file|
        cmd = {
          dst: { name: next_compute_site, file: "/pipelines/#{@pipeline_hash}/in" },
          src: { name: prev_compute_site, file: "/pipelines/#{@pipeline_hash}/out/#{file}" }
        }

        cmds.append(cmd)
      end

      cmds
    end
  end
end