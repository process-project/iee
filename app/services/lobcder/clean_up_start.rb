# frozen_string_literal: true

module Lobcder
  class CleanUpStart < StartBase
    def initialize(computation)
      super(computation)
    end

    def call
      rm_directories
    end

    def rm_directories
      rm(rm_cmds)
    end

    def rm_cmds
      cmds = []

      pipeline_site_names.each do |site_name|
        cmd = { name: site_name.to_s, path: pipeline_dirs[:pipeline] }
        cmds.append(cmd)
      end

      cmds
    end
  end
end
