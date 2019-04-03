# frozen_string_literal: true

class StagingInStep < Step
  attr_reader :parameters, :tmp_output_files

  def initialize(name, parameters = [], tmp_output_files = [])
    super(name, [])
    @parameters = parameters
    @tmp_output_files = tmp_output_files
  end

  def builder_for(pipeline, params)
    @src_host = params[:src_host]
    @src_path = params[:src_path]
    @dest_host = params[:dest_host]
    @dest_path = params[:dest_path]

    PipelineSteps::StagingIn::Builder.new(pipeline, name, @src_host,
                                          @src_path, @dest_host,
                                          @dest_path, @parameters)
  end

  def runner_for(computation, options = {})
    PipelineSteps::StagingIn::Runner.new(computation,
                                         @src_host,
                                         @src_path,
                                         @dest_host,
                                         @dest_path,
                                         options)
  end
end
