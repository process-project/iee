# frozen_string_literal: true

# rubocop:disable ClassLength

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    tensorflow_pipeline: %w[tf_cpu_step tf_gpu_step],
    singularity_test_gpu_pipeline: %w[singularity_test_gpu_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    lufthansa_pipeline: %w[lufthansa_step],
    agrocopernicus_pipeline: %w[agrocopernicus_step],
    staging_in_placeholder_pipeline: %w[staging_in_step]

  }.freeze

  STEPS = [
    StagingInStep.new('staging_in_step',
                      [
                        StepParameter.new(
                            'src_host',
                            'Source Host',
                            'Descriptions are for loosers',
                            '0',
                            'multi',
                            'data03.process-project.eu',
                            %w[data03.process-project.eu]
                          ),
                        StepParameter.new(
                            'src_path',
                            'Source Path',
                            'Descriptions are for loosers',
                            '1',
                            'multi',
                            '/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif',
                            %w[/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif]
                          ),
                        StepParameter.new(
                            'dest_host',
                            'Destination Host',
                            'Descriptions are for loosers',
                            '2',
                            'multi',
                            'pro.cyfronet.pl',
                            %w[pro.cyfronet.pl]
                          ),
                        StepParameter.new(
                            'dest_path',
                            'Destination Path',
                            'Descriptions are for loosers',
                            '3',
                            'multi',
                            '/net/archive/groups/plggprocess/UC1/test_staging_2',
                            %w[/net/archive/groups/plggprocess/UC1/test_staging_2]
                          )
                      ]),
    RimrockStep.new('placeholder_step',
                    'process-eu/mock-step',
                    'mock.sh.erb', [], []),
    RimrockStep.new('tf_cpu_step',
                    'process-eu/tensorflow-pipeline',
                    'tensorflow_cpu_mock_job.sh.erb', [], []),
    RimrockStep.new('tf_gpu_step',
                    'process-eu/tensorflow-pipeline',
                    'tensorflow_gpu_mock_job.sh.erb', [], []),
    RimrockStep.new('singularity_test_gpu_step',
                    'process-eu/singularity-pipeline',
                    'singularity_mock_job.sh.erb',
                    [:generic_type], []),
    SingularityStep.new('singularity_placeholder_step',
                        'shub://',
                        'vsoch/hello-world',
                        'latest', [], []),
    SingularityStep.new('medical_step',
                        'shub://',
                        'maragraziani/ucdemo',
                        '0.1', [], []),
    SingularityStep.new('lofar_step',
                        'shub://',
                        'lofar/lofar_container',
                        'latest',
                        [],
                        [
                          StepParameter.new(
                            'environment',
                            'Resources',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Cyfronet',
                            %w[Cyfronet Munich]
                          ),
                          StepParameter.new(
                            'visibility_id',
                            'LOFAR Visibility ID',
                            'LOFAR visibility identifier',
                            '1',
                            'string',
                            ''
                          ),
                          StepParameter.new(
                            'avg_freq_step',
                            'Average frequency step',
                            'Corresponds to .freqstep in NDPPP or demixer.freqstep',
                            '2',
                            'integer',
                            2
                          ),
                          StepParameter.new(
                            'avg_time_step',
                            'Average time step',
                            'Corresponds to .timestep in NDPPP or demixer.timestep',
                            '3',
                            'integer',
                            4
                          ),
                          StepParameter.new(
                            'do_demix',
                            'Perform demixer',
                            'If true then demixer instead of average is performed',
                            '4',
                            'boolean',
                            true
                          ),
                          StepParameter.new(
                            'demix_freq_step',
                            'Demixer frequency step',
                            'Corresponds to .demixfreqstep in NDPPP',
                            '5',
                            'integer',
                            2
                          ),
                          StepParameter.new(
                            'demix_time_step',
                            'Demixer time step',
                            'Corresponds to .demixtimestep in NDPPP',
                            '6',
                            'integer',
                            2
                          ),
                          StepParameter.new(
                            'demix_sources',
                            'Demixer sources',
                            '',
                            '7',
                            'multi',
                            'CasA',
                            %w[CasA other]
                          ),
                          StepParameter.new(
                            'select_nl',
                            'Use NL stations only',
                            'If true then only Dutch stations are selected',
                            '8',
                            'boolean',
                            true
                          ),
                          StepParameter.new(
                            'parset',
                            'Parameter set',
                            '',
                            '9',
                            'multi',
                            'lba_npp',
                            %w[lba_npp other]
                          )
                        ]),
    SingularityStep.new('agrocopernicus_step',
                        'shub://',
                        'vsoch/hello-world',
                        'latest', ['input.csv'],
                        [
                          StepParameter.new(
                            'environment',
                            'Resources',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Cyfronet',
                            %w[Cyfronet Munich]
                          ),
                          StepParameter.new(
                            'irrigation',
                            'Irrigation',
                            '',
                            '1',
                            'boolean',
                            'true'
                          ),
                          StepParameter.new(
                            'seeding_date',
                            'Seeding date',
                            '',
                            '2',
                            'multi',
                            '-15 days',
                            ['-15 days', 'original', '+15 days']
                          ),
                          StepParameter.new(
                            'nutrition_factor',
                            'Nutrition factor',
                            '',
                            '3',
                            'multi',
                            '0.25',
                            ['0.25', '0.45', '0.60']
                          ),
                          StepParameter.new(
                            'Phenology_factor',
                            'Phenology factor',
                            '',
                            '4',
                            'multi',
                            '0.6',
                            ['0.6', '0.8', '1.0', '1.2']
                          )
                        ])
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
