# frozen_string_literal: true

class StagingInStep < Step
  attr_reader :parameters

	def initialize(name, src_host, src_path, dest_host, dest_path, parameters = [])
    super(name, [])

		@src_host = src_host
		@src_path = src_path
		@dest_host = dest_host
		@dest_path = dest_path
    @parameters = parameters
	end

  def builder_for(pipeline, _params)
    PipelineSteps::StagingIn::Builder.new(pipeline,
                                          name,
                                          @src_host,
                                          @src_path,
                                          @dest_host,
                                          @dest_path,
                                          @parameters)
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
