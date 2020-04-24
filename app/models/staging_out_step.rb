# frozen_string_literal: true

class StagingOutStep < Step
  attr_reader :parameters

  def initialize(name)
    super(name)
    host_list = Lobcder::Service.new.host_aliases.map(&:to_s)
    @parameters = [
      StepParameter.new(
        label: 'dest_host',
        name: 'Destination Host',
        description: 'Descriptions placeholder',
        rank: 2,
        datatype: 'multi',
        default: host_list[0],
        values: host_list
      ),
      StepParameter.new(
        label: 'dest_path',
        name: 'Destination Path',
        description: 'Descriptions placeholder',
        rank: 3,
        datatype: 'string',
        default: ''
      )
    ]
  end

  def builder_for(pipeline, params)
    @dest_host = params[:dest_host]
    @dest_path = params[:dest_path]
    PipelineSteps::Lobcder::Builder.new(pipeline,
                                        name,
                                        dest_host = @dest_host,
                                        dest_path = @dest_path)
  end

  def runner_for(computation, options = {})
    PipelineSteps::Lobcder::Runner.new(computation, options)
  end
end
