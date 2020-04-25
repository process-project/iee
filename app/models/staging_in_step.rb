# frozen_string_literal: true

class StagingInStep < Step
  attr_reader :parameters

  def initialize(name)
    super(name)
    # TODO: consistent compute site naming convention
    host_list = Lobcder::Service.new.sites.map(&:to_s)
    @parameters = [
      StepParameter.new(
        label: 'src_host',
        name: 'Source Compute Site',
        description: 'Descriptions placeholder',
        rank: 0,
        datatype: 'multi',
        default: host_list[0],
        values: host_list
      ),
      StepParameter.new(
        label: 'src_path',
        name: 'Source Path',
        description: 'Descriptions placeholder',
        rank: 1,
        datatype: 'string',
        default: ''
      )
    ]
  end

  def builder_for(pipeline, params)
    @src_host = params[:src_host]
    @src_path = params[:src_path]
    PipelineSteps::Lobcder::Builder.new(pipeline,
                                        name,
                                        src_host = @src_host,
                                        src_path = @src_path)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Lobcder::Runner.new(computation, options)
  end
end
