# frozen_string_literal: true

class StagingInStep < Step
	def iniatilize(src_host, src_path, dest_host, dest_path)
		@src_host = src_host
		@src_path = src_path
		@dest_host = dest_host
		@dest_path = dest_path
	end

  def builder_for(pipeline, params)
    PipelineSteps::StagingIn::Builder.new(pipeline,
                                          name,
                                          @src_host,
                                          @src_path,
                                          @dest_host,
                                          @dest_path,
                                          params
                                          )
  end

  def runner_for(computation, options = {})
    PipelineSteps::StagingIn::Runner.new(computation,
                                          name,
                                          @src_host
                                          @src_path,
                                          @dest_host,
                                          @dest_path,
                                          options)
  end
end