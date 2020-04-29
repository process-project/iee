# frozen_string_literal: true

module Lobcder
  class StagingInStart < StartBase
    def initialize(computation)
      super(computation)
      @src_site_name = computation.src_compute_site.name.to_sym
      @next_site_name = computation.next.compute_site.name.to_sym

      @src_path = computation.input_path
    end

    def call
      move_files
    end

    private

    def move_files
      move(cmds)
    end

    # TODO: assuming src path is a directory
    def cmds
      cmds = []

      dir_files(@src_site_name, @src_path).each do |file|
        cmd = {
          dst: { name: @next_site_name.to_s, path: pipeline_dirs[:in] },
          src: { name: @src_site_name.to_s, path: file }
        }

        cmds.append(cmd)
      end

      cmds
    end
  end
end
