# frozen_string_literal: true

class CloudkStep < Step
  attr_reader :repo, :file

  def initialize(atmosphere_url, name, repository, file, required_files = [])
    super(name, required_files)

    @atmosphere_url = atmosphere_url
    @repository = repository
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Cloud::Builder.new(pipeline, @atmosphere_url, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Cloud::Runner.new(computation, @atmosphere_url, @repository, @file, options)
  end
end
