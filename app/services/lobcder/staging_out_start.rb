# frozen_string_literal: true

module Lobcder
  class StagingOutStart < StartBase
    def initialize(computation)
      super(computation)
      @dest_site_name = computation.dest_compute_site.name.to_sym
      @prev_site_name = computation.prev.compute_site.name.to_sym

      @dest_path = computation.output_path
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
          dst: { name: @dest_site_name.to_s, file: @dest_path },
          src: { name: @prev_site_name.to_s, file: file }
        }
        cmds.append(cmd)
      end

      cmds
    end
  end
end
