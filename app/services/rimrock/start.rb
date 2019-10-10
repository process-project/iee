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
        # PLACEHOLDER -- NOT FOR PRODUCTION USE
        if computation.hpc == 'CoolMUC'
          req.headers['SSH_PUB_KEY'] = "c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCQVFEUGo3YURHQWFuWVkvSHhTMDg4emtjQmVzSFZGSGV1ZHVkRGhjY29DYjQ0RHJQSVZ0eTFXb1pQUU5MVlpCeWw2VFV1bmU5UHlDaHZtOTd1dEpBSDIvQ0tHU25DaXRLbVFIbG1MSlkyQStSL0Y2d2l4Qm9WY3NzSWRMVHRZZmg5OXlwNnV2M1dtaS9jYitoWVlJZkVkdm5mUFZQMkF6NlozZVJXaXI5TnFlSENJMFpTK1dnUjh1ZlhZQ3VZc0huczhFWEp0dTFQeFZKVkNqYS9BR01yVTcwZFdBWVREdTEzRWhlaTRYV3Qrd25KdDE4RWxkNGVkRUhNeWhGMWVTU29USGpLMDFjem1YL3FRR0dXeTJKT04zamhwRjZkeno3TnVYODQ3Vzl0V3BzaFVMUGZZa3dUNjhrVW56aTVoQjZPaTZaRk1qQ1YzVGxxbGEyaEcxSjI1YjcgcnJ0MkBqbS10NDgwCg=="
          req.headers['SSH_PRIV_KEY'] = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBejQrMmd4Z0dwMkdQeDhVdFBQTTVIQVhyQjFSUjNybmJuUTRYSEtBbStPQTZ6eUZiCmN0VnFHVDBEUzFXUWNwZWsxTHAzdlQ4Z29iNXZlN3JTUUI5dndpaGtwd29yU3BrQjVaaXlXTmdQa2Z4ZXNJc1EKYUZYTExDSFMwN1dINGZmY3FlcnI5MXBvdjNHL29XR0NIeEhiNTN6MVQ5Z00rbWQza1ZvcS9UYW5od2lOR1V2bApvRWZMbjEyQXJtTEI1N1BCRnliYnRUOFZTVlFvMnZ3QmpLMU85SFZnR0V3N3RkeElYb3VGMXJmc0p5YmRmQkpYCmVIblJCek1vUmRYa2txRXg0eXROWE01bC82a0JobHN0aVRqZDQ0YVJlbmM4K3pibC9PTzF2YlZxYklWQ3ozMkoKTUUrdkpGSjg0dVlRZWpvdW1SVEl3bGQwNWFwV3RvUnRTZHVXK3dJREFRQUJBb0lCQUh5dy9sa1U5dkpaRnZKUgpUeEw5bndKcHY3OEFkY3FTNXc4YjV1Q0lpY0VibTlqUlZrblBVZFRscFhQOWJEQ2JUeWVJK2VRVDUzdWpsdi9DCnhRcEdtSElRcUI3OWFmSi9wdmNTVzVvcCtuaWVIeGg2QXBwYmFCb1VHNzZab0k4c3cwREU0NHNPb2p6WWplSGEKWFR4akV6T25Dd3d6WStDT2hmTXBNd2c1YkQwZTNnYUhNYmE1TjhKTnJ2QmRzb04rSmd4VmdodEVXdEpDMHp2RwowMkZkT3JrMm9HdFZCZHVKMDM5SHN1MVRkRHdWeE9mZ0lMUmZCMEtJVmQveW5FdTRoTEN1UldQZFRCVGJxb2dJCmpUYy9UMSt3djcwQkNLbUljUkxOTmpvK2ZrRXZOOTcwQ2JEbVJSdUQzS0JkVTdjVVRDd25hbk9TUUw5YWZ5bXEKV3lWK3Rqa0NnWUVBNTBzL05lVlgra3lFdzVuVWU2MkJIekhPRTEvUm9kNTZBRjlnejBIbTdIclZ5Smpmb0phRQo5UG9DN1J3cFc0bzBnOVhZWnNOcHBKMXRRclcyNUZOdmZDejBkY1JzeUM4Rm9kQWJRQUo0OE5yU2lsaXc0U2JkCkExd2NsLzA1dkpLS1hjaERyb0NtWGs4VzFadnVZd3pnN2pVRnNucGQydytmeXNPbEt5bmxoTmNDZ1lFQTVidC8KU1hoTHNxTFk4RWRYTnMyQ0pzRFFSWURoQ20yWGlHdHFUaGFFMTJpY2VzY1FLWW1hV0J6V3FVYmNJN3E3dzQzQwpGa2w2alh0SlJhSEFoWTl1NFZxRFpqQkxuUHRRWnhTMnZlWVJ1Z1licUd2NjMzOFBlZUc2RmVUcXdxRFYwWWJnCjg0bkY1a3VGcVQxSzNkOXNpc1JpeXdTSkhkQ1ZqN1prTGJCeTFuMENnWUFBOGlIVUNwZ05nZnFaQWl3SVJYRmQKdTBwb2NkL2RsWmRTSVJHNFIwQzJmdG9ZOCtjV05RZGVLUmVSK0tlQ3BGSUtwL2sya2w0QU9sU1VEVUl1Tk5ragozTnN6RUJhUnl2OXU1ZmIya0F3R2tCNkVTbENPMnlYVU9iQTBQdWpaaUkvZ1NrMWNqVklnMkpuelRhdnY0OEdYCnQ4ZktMdzNyTTJrbjN4enh6RDRRQ1FLQmdFYWlMWEt6YitMT3V4QzFmcFUwL28xWHZ6Ri9mTEd1SEdjdlQ1SU8Kem0xRWxzZ1JLR0Q5RTkxL2tHaWZodFBkZUJtYUhsQ242dXhST2FnVklaSnZGVkpvZC9vVlkwb3k0dmV1b0xrbQpZZERtUzk2dXhJV3ZGVjBPRUI3bk1WOENBSHZaa3BTT2liQlREQmVLNXRmczkveDZnVDJXZVdvWFZjVEgrV2txCjFVUXBBb0dCQU9HL08xQVlWd0JuUStXb2dzak9HTlFSeG8rMEx1NUxxajNFYkp4ZHB3WlVGemF2VDBLZi9zazEKdFpJYmF0VTFyYnZxVHZRZ1hmRTNOZExnblAxeUVFaDY2TXZPM3pkV09zeXc2NXhBRG45UExMUGtZdDBQNHgxOQpjcmxSY0ttVVM5bTBYRytOMFJrVjIvdzVTMTVxUjNoMTJmRzV4S1JKTXBNa0FYMzVsL3FiCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg=="
        end
        req.body = req_body
      end
    end

    def req_body

      Rails.logger.debug("STARTING RIMROCK JOB FOR HPC: #{computation.hpc}")

      case computation.hpc
      when 'CoolMUC'
      # TODO - PARAMETERIZE
      host = 'lxlogin5.lrz.de'
      script = "#!/bin/bash\n#SBATCH -A process2\necho hello\nsleep 300\nexit 0"
      {
        host: host,
        working_directory: computation.working_directory,
        script: script,
        tag: Rails.application.config_for('process')['rimrock']['tag']
      }.to_json
      else
      {
        host: Rails.application.config_for('process')['rimrock']['host'],
        working_directory: computation.working_directory,
        script: computation.script,
        tag: Rails.application.config_for('process')['rimrock']['tag']
      }.to_json
      end
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
