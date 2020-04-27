# frozen_string_literal: true

module Lobcder
  class StagingInStart < StartBase
    def initialize(computation)
      super(computation)
    end

    def call
      @src_compute_site = @computation.src_host # TODO: consistent naming convention
      @next_compute_site = @computation.next.hpc # TODO: assuming next step is a singularity step

      @src_path = @computation.src_path # TODO: assuming src_path is a folder or file?

      move(mv_output_cmds)
    end

    private

    def mv_output_cmds
      [
        {
          dst: { name: @next_compute_site, file: "/pipelines/#{@pipeline_hash}/in" },
          src: { name: @src_compute_site, file: @src_path }
        }
      ]
    end
  end
end
