# frozen_string_literal: true

class WebdavStep < Step
  attr_reader :name

  def builder_for(pipeline, params)
    PipelineSteps::Webdav::Builder.new(pipeline, name, params)
  end
end
