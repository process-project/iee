# frozen_string_literal: true

module PipelineStep
  class RimrockBase < Base
    def initialize(computation, repo_name, filename, options = {})
      super(computation)
      @repo_name = repo_name
      @filename = filename
      @template_fetcher = options.fetch(:template_fetcher) { Gitlab::GetFile }
      @revision_fetcher = options.fetch(:revision_fetcher) { Gitlab::Revision }
    end

    def runnable?
      false
    end

    protected

    def pre_internal_run
      computation.revision = revision
      computation.script = ScriptGenerator.new(computation, template).call
      computation.job_id = nil
    end

    def internal_run
      Rimrock::StartJob.perform_later computation if computation.valid?
    end

    def template
      @template_fetcher.new(@repo_name, @filename, computation.revision).call
    end

    def revision
      @revision_fetcher.new(@repo_name, computation.tag_or_branch).call
    end
  end
end
