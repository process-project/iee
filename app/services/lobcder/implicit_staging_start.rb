# frozen_string_literal: true

module Lobcder
  class ImplicitStagingStart < StartBase
    # TODO: rm 'in'
    def initialize(computation)
      super(computation)
    end

    def call
      # TODO: consistent compute site naming convention
      @prev_compute_site = @computation.prev.hpc # TODO: implement next, prev computation
      @next_compute_site = @computation.next.hpc # TODO: assuming next/prev steps are SINGULARITY STEPS

      rm(rm_prev_input_cmds)
      move(mv_output_cmds)
    end

    private

    def mv_output_cmds
      # TODO: moving folders works?
      cmds = []

      output_files(@prev_compute_site).each do |file|
        cmd = {
          dst: { name: @next_compute_site, file: "/pipelines/#{@pipeline_hash}/in" },
          src: { name: @prev_compute_site, file: "/pipelines/#{@pipeline_hash}/out/#{file}" }
        }

        cmds.append(cmd)
      end

      cmds
    end

    def rm_prev_input_cmds
      cmds = []

      input_files(@prev_compute_site).each do |file|
        cmd = {
          name: @prev_compute_site, file: "/pipelines/#{@pipeline_hash}/in/#{file}", recursive: true
        }

        cmds.append(cmd)
      end

      cmds
    end

    def output_files(site)
      @service.list(site, "/pipelines/#{@pipeline_hash}/out")
    end

    def input_files(site)
      @service.list(site, "/pipelines/#{@pipeline_hash}/in")
    end
  end
end
