# frozen_string_literal: true

class WebdavStep < Step
  attr_reader :run_modes

  def initialize(name, run_modes, required_files = [])
    super(name, required_files)
    @run_modes = run_modes
  end

  def builder_for(pipeline, params)
    PipelineSteps::Webdav::Builder.new(pipeline, name, params)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Webdav::Runner.new(computation, required_files.first, options)
  end
end
