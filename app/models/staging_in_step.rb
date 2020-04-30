# frozen_string_literal: true

class StagingInStep < LobcderStep
  # rubocop:disable MethodLength
  def initialize(name)
    super(name)
    compute_site_names = ComputeSite.all.map(&:full_name)
    @parameters = [
      StepParameter.new(
        label: 'src_compute_site_name',
        name: 'Source Compute Site Name',
        description: 'Descriptions placeholder',
        rank: 0,
        datatype: 'multi',
        default: compute_site_names[0],
        values: compute_site_names
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
  # rubocop:enable MethodLength

  def builder_for(pipeline, params)
    PipelineSteps::Lobcder::Builder.new(pipeline,
                                        name,
                                        src_compute_site_name: params[:src_compute_site_name],
                                        src_path: params[:src_path])
  end

  def runner_for(computation, options = {})
    PipelineSteps::Lobcder::Runner.new(computation, options)
  end
end
