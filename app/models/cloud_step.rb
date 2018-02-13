# frozen_string_literal: true

class CloudStep < Step
  attr_reader :repo, :file

  def initialize(name, repository, file, required_files = [])
    super(name, required_files)

    @repository = repository
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Cloud::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Cloud::Runner.new(computation, @repository, @file, options)
  end
end
