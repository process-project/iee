# frozen_string_literal: true

class StagingOutStep < LobcderStep
  # rubocop:disable MethodLength
  def initialize(name)
    super(name)
    compute_site_names = ComputeSite.all.map(&:full_name)
    @parameters = [
      StepParameter.new(
        label: 'dest_compute_site_name',
        name: 'Destination Compute Site Name',
        description: 'Descriptions placeholder',
        rank: 2,
        datatype: 'multi',
        default: compute_site_names[0],
        values: compute_site_names
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
  # rubocop:enable MethodLength

  def builder_for(pipeline, params)
    PipelineSteps::Lobcder::Builder.new(pipeline,
                                        name,
                                        dest_compute_site_name: params[:dest_compute_site_name],
                                        dest_path: params[:dest_path])
  end

  def runner_for(computation, options = {})
    PipelineSteps::Lobcder::Runner.new(computation, options)
  end
end
