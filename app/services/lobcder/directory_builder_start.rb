module Lobcder
  class DirectoryBuilderStart
    # TODO: what about
    def initialize(computation)
      uc_no = computation.pipeline.project.project_name.last.to_i # TODO: there should be usecase number in project table
      @service = Service.new(uc_no)
      @pipeline_hash = computation.pipeline.name
    end

    def call
      # TODO: use batch mkdir (one request)
      compute_sites.each do |compute_site|
        paths.each do |path|
          @service.mkdir(compute_site, path)
        end
      end
    end

    private

    def compute_sites
      compute_sites = Set.new
      computation.pipeline.computations.each do |c|
        # TODO: compute_site/host/hpc inconsistency between computation and LOBCDER API json
        compute_site = c.hpc.to_sym
        unless container_exist? compute_site, c.container_name
          # throw exception
        end
        compute_sites.add(compute_site) if c.need_directory_structure?
      end
      compute_sites
    end

    def paths
      [
          File.join("/","containers"),
          File.join("/","pipelines", @pipeline_hash, "in"),
          File.join("/","pipelines", @pipeline_hash, "workdir"),
          File.join("/","pipelines", @pipeline_hash, "out")
      ]
    end

    # TODO: finish, make computation: status hash
    def check_containers
      computation.pipeline.computations.map do |c|
        status = container_exist? c.hpc.to_sym, c.container_name
        [c, status]
      end
    end

    def container_exist?(compute_site, container_name)
      # TODO: container/container image naming convention
      @service.list(compute_site, File.join("/","containers")).include? container_name
    end
  end
end
