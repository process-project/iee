# frozen_string_literal: true

class WebdavStep < Step
  def builder_for(pipeline, params)
    PipelineSteps::Webdav::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Webdav::Runner.new(computation, required_files.first, options)
  end
end