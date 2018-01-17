# frozen_string_literal: true

class RimrockStep
  attr_reader :name, :repo, :file

  def initialize(name, repo, file)
    @name = name
    @repo = repo
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Rimrock::Builder.new(pipeline, name, params)
  end
end
