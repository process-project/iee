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
      copy_files
    end

    private

    def copy_files
      if output_files(@prev_site_name).empty?
        @computation.update_attributes(status: 'finished')
        Lobcder::UpdateJob.perform_later(@computation)
      else
        copy(cp_cmds)
      end
    end

    def cp_cmds
      cmds = []

      output_files(@prev_site_name).each do |file|
        cmd = {
          dst: { name: @dest_site_name.to_s, path: @dest_path },
          src: { name: @prev_site_name.to_s, path: file }
        }
        cmds.append(cmd)
      end

      cmds
    end
  end
end
