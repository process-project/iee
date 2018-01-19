# frozen_string_literal: true

class RimrockStep < Step
  attr_reader :repo, :file

  def initialize(name, repo, file, required_files = [])
    super(name, required_files)

    @repo = repo
    @file = file
  end

  def builder_for(pipeline, params)
    PipelineSteps::Rimrock::Builder.new(pipeline, name, params)
  end
end
