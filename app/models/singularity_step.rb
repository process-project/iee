# frozen_string_literal: true

class SingularityStep < Step
  attr_reader :repository, :file

  def initialize(name, registry_url, container_name, container_tag)
    super(name, [])
    @registry_url = registry_url
    @container_name = container_name
    @container_tag = container_tag
  end

  def builder_for(pipeline, params)
    PipelineSteps::Singularity::Builder.new(pipeline, name, @registry_url, @container_name, @container_tag)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Singularity::Runner.new(computation, @registry_url, @container_name, @container_tag, options)
  end
end
