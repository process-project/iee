# frozen_string_literal: true

# rubocop:disable ClassLength
class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    agrocopernicus_pipeline: %w[agrocopernicus_step],
    staging_in_placeholder_pipeline: %w[staging_in_step],
    validation_pipeline: %w[validation_staging_in_step
                            validation_singularity_step
                            validation_stage_out_step]
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
      ],
      'staging_done.txt'
    ),
    StagingInStep.new(
      'validation_staging_in_step',
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
          default: '/mnt/dss/process/UC1/1G.dat',
          values: %w[/mnt/dss/process/UC1/1G.dat /mnt/dss/process/UC1/10M.dat]
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
          default: '/net/archive/groups/plggprocess/Mock/validation_staging',
          values: %w[/net/archive/groups/plggprocess/Mock/validation_staging]
        )
      ],
      'staging_done.txt'
    ),
    SingularityStep.new('validation_singularity_step',
                        ['staging_done.txt']),
    RimrockStep.new('validation_stage_out_step',
                    'process-eu/validation_stage_out',
                    'validation_stage_out_script.sh.erb', [:validation_type], []),
    RimrockStep.new('placeholder_step',
                    'process-eu/mock-step',
                    'mock.sh.erb', [], []),
    SingularityStep.new('singularity_placeholder_step'),
    SingularityStep.new('medical_step'),
    SingularityStep.new('lofar_step'),
    RestStep.new(
      'agrocopernicus_step',
      [
        StepParameter.new(
          label: 'irrigation',
          name: 'Irrigation',
          description: '',
          rank: 0,
          datatype: 'boolean',
          default: 'true'
        ),
        StepParameter.new(
          label: 'seeding_date',
          name: 'Seeding date',
          description: '',
          rank: 0,
          datatype: 'multi',
          default: '-15 days',
          values: ['-15 days', 'original', '+15 days']
        ),
        StepParameter.new(
          label: 'nutrition_factor',
          name: 'Nutrition factor',
          description: '',
          rank: 0,
          datatype: 'multi',
          default: '0.25',
          values: ['0.25', '0.45', '0.60']
        ),
        StepParameter.new(
          label: 'phenology_factor',
          name: 'Phenology factor',
          description: '',
          rank: 0,
          datatype: 'multi',
          default: '0.6',
          values: ['0.6', '0.8', '1.0', '1.2']
        )
      ]
    )
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
# rubocop:enable ClassLength
