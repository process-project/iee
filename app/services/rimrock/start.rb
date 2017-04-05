# frozen_string_literal: true
module Rimrock
  class Start < Rimrock::Service
    def call
      raise Rimrock::Exception, 'Cannot start computation twice' if computation.job_id

      response = make_call
      case response.status
      when 201 then success(response.body)
      else failure(response.body)
      end
    end

    private

    def make_call
      connection.post do |req|
        req.url 'api/jobs'
        req.headers['Content-Type'] = 'application/json'
        req.body = req_body
      end
    end

    def req_body
      {
        host: Rails.application.config_for('eurvalve')['rimrock']['host'],
        working_directory: computation.working_directory,
        script: computation.script,
        tag: Rails.application.config_for('eurvalve')['rimrock']['tag']
      }.to_json
    end

    def success(body)
      body_json = JSON.parse(body)

      computation.update_attributes(
        job_id: body_json['job_id'],
        status: body_json['status'].downcase,
        stdout_path: body_json['stdout_path'],
        stderr_path: body_json['stderr_path']
      )
    end

    def failure(body)
      body_json = JSON.parse(body)

      computation.update_attributes(
        status: body_json['status'].downcase,
        exit_code: body_json['exit_code'],
        standard_output: body_json['standard_output'],
        error_output: body_json['error_output'],
        error_message: body_json['error_message']
      )
    end
  end
end
