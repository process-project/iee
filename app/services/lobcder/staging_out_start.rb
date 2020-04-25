module Lobcder
  class StagingOutStart < StartBase
    def initialize(computation)
      super(computation)
    end

    def call
      dst_compute_site = @computation.dst_host # TODO: consistent naming convention
      dst_path = @computation.dst_path # TODO: assuming dst_path is a folder or file?

      prev_compute_site = @computation.prev_computation.hpc # TODO: assuming next step is a singularity step

      cmds = [
        {
          dst: { name: dst_compute_site, file: dst_path },
          src: { name: prev_compute_site, file: "/pipelines/#{@pipeline_hash}/out" } # TODO: move whole folder? Can you even move folder with LOBCDER?
        }
      ]

      move(cmds)
    end
  end
end