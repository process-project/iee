# frozen_string_literal: true

module Lobcder
  class StartBase
    def initialize(computation)
      @computation = computation
      @service = Service.new(computation.uc)
      @pipeline_name = computation.pipeline.name
    end

    protected

    def move(cmds)
      response = @service.move(cmds)
      status = response[:status]

      if status == 'QUEUED' # TODO: check
        @computation.status = 'queued' # TODO: check
        track_id = response[:track_id]
        @computation.track_id = track_id
      else
        @computation.status == 'error'
      end
    rescue Lobcder::Exception
      @computation.status == 'error' # TODO: check
    end

    def rm(cmds)
      @service.rm(cmds)
      @computation.status == 'finished' # TODO: check
    rescue Lobcder::Exception
      @computation.status = 'error' # TODO: check
    end

    def mkdir(cmds)
      @service.mkdir(cmds)
      @computation.status == 'finished' # TODO: check
    rescue Lobcder::Exception
      @computation.status = 'error' # TODO: check
    end

    def containers(site_name)
      @service.list(site_name, root_dirs[:containers])
    end

    def output_files(site_name)
      out_dir = pipeline_dirs[:out]
      @service.list(site_name, out_dir) - [pipeline_dirs[:out]]
    end

    def input_files(site_name)
      in_dir = pipeline_dirs[:in]
      @service.list(site_name, in_dir) - [pipeline_dirs[:in]]
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
  end

  class Exception < RuntimeError
  end
end
