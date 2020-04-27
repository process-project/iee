# frozen_string_literal: true

module Lobcder
  class StartBase
    def initialize(computation)
      @computation = computation
      @service = Service.new(uc_for(computation))
      @pipeline_name = computation.pipeline.name
    end

    protected

    def move(cmds)
      track_id = @service.move(cmds) # TODO: move of copy?
      update_status('queued? ') # TODO: get status from response
      @computation.track_id = track_id
    rescue LOBCDER_FAILURE
      # TODO: handle error
      update_status('error')
    ensure
    end

    def rm(cmds)
      @service.rm(cmds)
    rescue LOBCDER_FAILURE
    ensure
    end

    def mkdir(cmds)
      @service.mkdir(cmds)
    rescue LOBCDER_FAILURE
    ensure
    end

    def containers(site_name)
      @service.list(site_name, root_dirs[:containers])
    end

    def output_files(site_name)
      out_dir = pipeline_dirs[:out]
      @service.list(site_name, out_dir)
    end

    def input_files(site_name)
      in_dir = pipeline_dirs[:in]
      @service.list(site_name, in_dir)
    end

    def pipeline_dirs
      {
        in: File.join('/', ['pipelines', @pipeline_name, 'in']),
        out: File.join('/', ['pipelines', @pipeline_name, 'out']),
        workdir: File.join('/', ['pipelines', @pipeline_name, 'workdir'])
      }
    end

    def root_dirs
      {
        pipelines_root: File.join('/', 'pipelines'),
        containers: File.join('/', 'containers')
      }
    end

    private

    def uc_for(computation)
      Flow.uc_for(computation.pipeline.flow.to_sym)
    end
  end

  class Exception < RuntimeError
  end
end
