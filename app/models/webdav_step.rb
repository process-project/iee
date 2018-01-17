# frozen_string_literal: true

class WebdavStep
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def builder_for(pipeline, params)
    PipelineSteps::Webdav::Builder.new(pipeline, name, params)
  end
end
