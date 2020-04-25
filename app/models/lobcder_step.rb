# frozen_string_literal: true

class LobcderStep < Step
  def initialize(name)
    super(name)
  end

  # TODO: rak
  def builder_for(pipeline, _)
    PipelineSteps::Lobcder::Builder.new(pipeline, name)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Lobcder::Runner.new(computation, options)
  end

  # TODO: check
  def input_present_for?
    true
  end
end
