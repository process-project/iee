# frozen_string_literal: true
module ScriptGenerator
  class Computation
    def call
      header + stage_in + job_script + stage_out
    end

    def initialize(pipeline)
      @pipeline = pipeline
    end

    protected

    attr_reader :pipeline
    delegate :user, to: :pipeline

    private

    def header
      invalid_usage
    end

    def invalid_usage
      raise 'Method called on abstract base class. Use specializations of this class instead.'
    end

    def stage_in
      invalid_usage
    end

    def job_script
      invalid_usage
    end

    def stage_out
      invalid_usage
    end

    def grant_id
      Rails.application.config_for('eurvalve')['grant_id']
    end

    def stage_in_file(data_file, filename)
      "curl -H \"Authorization: Bearer #{user.token}\""\
        " \"#{data_file.url}\" >> \"$SCRATCHDIR/#{filename}\""
    end

    def stage_out_file(filename)
      "curl -X PUT --data-binary @#{filename} -H \"Content-Type:application/octet-stream\""\
        " -H \"Authorization: Bearer #{user.token}\""\
        " \"#{File.join(pipeline.working_url, filename)}\""
    end
  end
end
