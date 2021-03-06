# frozen_string_literal: true

module Lobcder
  class ImplicitStagingStart < StartBase
    def initialize(computation)
      super(computation)
      @prev_site_name = computation.prev.compute_site.name.to_sym
      @next_compute_site = computation.next.compute_site.name.to_sym
    end

    def call
      remove_prev_files
      move_output_files
    end

    private

    def remove_prev_files
      rm(rm_cmds)
    end

    def move_output_files
      move(mv_cmds)
    end

    def rm_cmds
      cmds = []

      files_to_delete = input_files(@prev_site_name) + workdir_files(@prev_site_name)

      files_to_delete.each do |file|
        cmd = {
          name: @prev_site_name.to_s, path: file
        }

        cmds.append(cmd)
      end

      cmds
    end

    def mv_cmds
      cmds = []

      output_files(@prev_site_name).each do |file|
        cmd = {
          dst: { name: @next_compute_site.to_s, path: pipeline_dirs[:in] },
          src: { name: @prev_site_name.to_s, path: file }
        }

        cmds.append(cmd)
      end

      cmds
    end
  end
end
