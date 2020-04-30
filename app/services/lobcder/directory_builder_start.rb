# frozen_string_literal: true

module Lobcder
  class DirectoryBuilderStart < StartBase
    def initialize(computation)
      super(computation)
    end

    def call
      create_dirs
    end

    private

    def create_dirs
      mkdir(dir_cmds)
    end

    def dir_cmds
      cmds = []

      pipeline_site_names.each do |site_name|
        pipeline_dirs.each_value do |dir_path|
          cmd = { name: site_name.to_s, path: dir_path }
          cmds.append(cmd)
        end
      end

      cmds
    end

    # rubocop:disable Metrics/AbcSize
    def check_containers
      @computation.pipeline.computations.each do |c|
        next if container_exist? c.compute_site.name.to_sym, c.container_name
        raise ServiceFailure, "There doesn't exist container for #{c.id} computation " \
                                  "of #{c.pipeline_step} (#{c.step.class.name}) " \
                                  "on #{c.compute_site.name.to_sym} (#{c.compute_site.full_name}) "\
                                  'compute site'
      end

      true
    end
    # rubocop:enable Metrics/AbcSize

    def container_exist?(site_name, container_name)
      containers(site_name).include? container_name
    end
  end
end
