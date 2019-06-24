# frozen_string_literal: true

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    agrocopernicus_pipeline: %w[agrocopernicus_step],
    staging_in_placeholder_pipeline: %w[staging_in_step],
    validation_pipeline: %w[validation_container_step]
  }.freeze

  STEPS = [
    StagingInStep.new(
      'staging_in_step',
      [
        StepParameter.new(
          label: 'src_host',
          name: 'Source Host',
          description: 'Descriptions placeholder',
          rank: 0,
          datatype: 'multi',
          default: 'data03.process-project.eu',
          values: ['data03.process-project.eu']
        ),
        StepParameter.new(
          label: 'src_path',
          name: 'Source Path',
          description: 'Descriptions placeholder',
          rank: 1,
          datatype: 'multi',
          default: '/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif',
          values: %w[/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif]
        ),
        StepParameter.new(
          label: 'dest_host',
          name: 'Destination Host',
          description: 'Descriptions placeholder',
          rank: 2,
          datatype: 'multi',
          default: 'pro.cyfronet.pl',
          values: %w[pro.cyfronet.pl]
        ),
        StepParameter.new(
          label: 'dest_path',
          name: 'Destination Path',
          description: 'Descriptions placeholder',
          rank: 3,
          datatype: 'multi',
          default: '/net/archive/groups/plggprocess/Mock/test_staging',
          values: %w[/net/archive/groups/plggprocess/Mock/test_staging]
        )
      ]
    ),
    RimrockStep.new('placeholder_step',
                    'process-eu/mock-step',
                    'mock.sh.erb', [], []),
    SingularityStep.new('singularity_placeholder_step'),
    SingularityStep.new('medical_step'),
    SingularityStep.new('lofar_step'),
    SingularityStep.new('agrocopernicus_step',
                        ['input.csv']),
    SingularityStep.new('validation_container_step')
  ].freeze

  steps_hsh = Hash[STEPS.map { |s| [s.name, s] }]
  FLOWS_MAP = Hash[FLOWS.map { |key, steps| [key, steps.map { |s| steps_hsh[s] }] }]

  def self.types
    FLOWS_MAP.keys
  end

  def self.steps(flow_type)
    FLOWS_MAP[flow_type.to_sym] || []
  end
end
