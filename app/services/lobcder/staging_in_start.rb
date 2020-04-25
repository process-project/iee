module Lobcder
  class StagingInStart < StartBase
    def initialize(computation)
      super(computation)
    end

    def call
      src_compute_site = @computation.src_host # TODO: consistent naming convention
      src_path = @computation.src_path # TODO: assuming src_path is a folder or file?

      next_compute_site = @computation.next_computation.hpc # TODO: assuming next step is a singularity step

      cmds = [
        {
          dst: { name: next_compute_site, file: "/pipelines/#{@pipeline_hash}/in" },
          src: { name: src_compute_site, file: src_path }
        }
      ]

      move(cmds)
    end
  end
end