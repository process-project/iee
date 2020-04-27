# frozen_string_literal: true

module Lobcder
  class StagingOutStart < StartBase
    def initialize(computation)
      super(computation)
      @dst_site_name = computation.compute_site.name.to_sym
      @prev_site_name = computation.prev.compute_site.name.to_sym

      @dst_path = computation.compute_site.name
    end

    def call
      move_files
    end

    private

    def move_files
      move(cmds)
    end

    def cmds
      cmds = []

      output_files(@prev_site_name).each do |file|
        cmd = {
          dst: { name: @dst_site_name.to_s, file: @dst_path },
          src: { name: @prev_site_name.to_s, file: File.join(pipeline_dirs[:out], file) }
        }
        cmds.append(cmd)
      end

      cmds
    end
  end
end
