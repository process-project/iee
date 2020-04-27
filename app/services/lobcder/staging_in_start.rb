# frozen_string_literal: true

module Lobcder
  class StagingInStart < StartBase
    def initialize(computation)
      super(computation)
      @src_site_name = computation.src_compute_site.name.to_sym
      @next_site_name = computation.next.compute_site.name.to_sym

      @src_path = computation.src_path
    end

    def call
      move_files
    end

    private

    def move_files
      move(cmds)
    end

    def cmds
      [
        {
          dst: { name: @next_site_name.to_s, file: pipeline_dirs[:in] },
          src: { name: @src_site_name.to_s, file: @src_path }
        }
      ]
    end
  end
end
