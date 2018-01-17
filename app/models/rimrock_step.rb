# frozen_string_literal: true

class RimrockStep < Step
  attr_reader :repo, :file

  def initialize(name, repo, file)
    super(name)

    @repo = repo
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Rimrock::Builder.new(pipeline, name, params)
  end
end
