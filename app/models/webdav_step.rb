# frozen_string_literal: true

class WebdavStep < Step
  def builder_for(pipeline, params)
    PipelineSteps::Webdav::Builder.new(pipeline, name, params)
  end
end
