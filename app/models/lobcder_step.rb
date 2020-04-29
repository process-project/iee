# frozen_string_literal: true

class LobcderStep < Step
  attr_reader :parameters

  def initialize(name)
    super(name)
    @parameters = []
  end

  def builder_for(pipeline, _)
    PipelineSteps::Lobcder::Builder.new(pipeline, name)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Lobcder::Runner.new(computation, options)
  end
end
