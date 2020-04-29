# frozen_string_literal: true

module Lobcder
  class StartBase
    def initialize(computation)
      @computation = computation
      @service = Service.new(computation.uc)
      @pipeline_dir_name = computation.pipeline.name
    end

    protected

    def move(cmds)
      info = @service.move(cmds)
      status = info[:status]

      if status == 'QUEUED' # TODO: check
        track_id = info[:track_id]

        @computation.update_attributes(status: 'queued')
        @computation.update_attributes(track_id: track_id)
      else
        @computation.update_attributes(status: 'error')
      end
    rescue Lobcder::ServiceFailure
      @computation.update_attributes(status: 'error')
    ensure
      Lobcder::UpdateJob.perform_later(@computation)
    end

    def rm(cmds)
      @service.rm(cmds)
      @computation.update_attributes(status: 'finished')
    rescue Lobcder::ServiceFailure
      @computation.update_attributes(status: 'error')
    ensure
      Lobcder::UpdateJob.perform_later(@computation)
    end

    def mkdir(cmds)
      @service.mkdir(cmds)
      @computation.update_attributes(status: 'finished')
    rescue Lobcder::ServiceFailure
      @computation.update_attributes(status: 'error')
    ensure
      Lobcder::UpdateJob.perform_later(@computation)
    end

    def containers(site_name) # TODO: catch exceptions
      @service.list(site_name, root_dirs[:containers])
    end

    def output_files(site_name) # TODO: catch exceptions
      out_dir = pipeline_dirs[:out]
      @service.list(site_name, out_dir)
    end

    def input_files(site_name) # TODO: catch exceptions
      in_dir = pipeline_dirs[:in]
      @service.list(site_name, in_dir)
    end

    def dir_files(site_name, dir_path) # TODO: catch exceptions
      @service.list(site_name, dir_path, false)
    end

    def pipeline_dirs
      {
        in: File.join('/', ['pipelines', @pipeline_dir_name, 'in']),
        out: File.join('/', ['pipelines', @pipeline_dir_name, 'out']),
        workdir: File.join('/', ['pipelines', @pipeline_dir_name, 'workdir'])
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
