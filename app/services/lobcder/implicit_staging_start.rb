# frozen_string_literal: true

module Lobcder
  class ImplicitStagingStart < StartBase
    def initialize(computation)
      super(computation)
      @prev_site_name = computation.prev.compute_site.name.to_sym
      @next_compute_site = computation.next.compute_site.name.to_sym
    end

    def call
      remove_prev_input_files
      move_output_files
    end

    private

    def remove_prev_input_files
      rm(rm_cmds)
    end

    def move_output_files
      move(mv_cmds)
    end

    def rm_cmds
      cmds = []

      input_files(@prev_site_name).each do |file|
        cmd = {
          name: @prev_site_name.to_s, path: File.join(pipeline_dirs[:in], file), recursive: true
        }

        cmds.append(cmd)
      end

      cmds
    end

    def mv_cmds
      cmds = []

      output_files(@prev_site_name).each do |file|
        cmd = {
          dst: { name: @next_compute_site.to_s, file: pipeline_dirs[:in] },
          src: { name: @prev_site_name.to_s, file: File.join(pipeline_dirs[:out], file) }
        }

        cmds.append(cmd)
      end

      cmds
    end
  end
end
