# frozen_string_literal: true

# rubocop:disable ClassLength

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    tensorflow_pipeline: %w[tf_cpu_step tf_gpu_step],
    singularity_test_gpu_pipeline: %w[singularity_test_gpu_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step validation_singularity_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    # lufthansa_pipeline: %w[lufthansa_step],
    agrocopernicus_pipeline: %w[agrocopernicus_step],
    staging_in_placeholder_pipeline: %w[staging_in_step],
    validation_pipeline: %w[validation_staging_in_step
                            validation_singularity_step
                            validation_stage_out_step],
    input_check_pipeline: %w[input_check_step1 input_check_step2],
  }.freeze

  STEPS = [
    RimrockStep.new('input_check_step1',
                    'process-eu/validation_stage_out',
                    'validation_stage_out_script.sh.erb', [], []),
    RimrockStep.new('input_check_step2',
                    'process-eu/validation_stage_out',
                    'validation_stage_out_script.sh.erb', [:generic_type], []),
    StagingInStep.new('validation_staging_in_step',
                      [
                        StepParameter.new(
                          'src_host',
                          'Source Host',
                          'Descriptions placeholder',
                          '0',
                          'multi',
                          'data03.process-project.eu',
                          %w[data03.process-project.eu]
                        ),
                        StepParameter.new(
                          'src_path',
                          'Source Path',
                          'Descriptions placeholder',
                          '1',
                          'multi',
                          '/mnt/dss/process/UC1/1G.dat',
                          %w[/mnt/dss/process/UC1/1G.dat]
                        ),
                        StepParameter.new(
                          'dest_host',
                          'Destination Host',
                          'Descriptions placeholder',
                          '2',
                          'multi',
                          'pro.cyfronet.pl',
                          %w[pro.cyfronet.pl]
                        ),
                        StepParameter.new(
                          'dest_path',
                          'Destination Path',
                          'Descriptions placeholder',
                          '3',
                          'multi',
                          '/net/archive/groups/plggprocess/Mock/validation_staging',
                          %w[/net/archive/groups/plggprocess/Mock/validation_staging]
                        )
                      ], ['staging_done.txt']),
    SingularityStep.new('validation_singularity_step',
                        ['staging_done.txt'],
                        [
                          StepParameter.new(
                            'hpc',
                            'HPC',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Prometheus',
                            %w[Prometheus]
                          ),
                          StepParameter.new(
                            'registry_url',
                            'Registry url',
                            'Singularity registry which contains containers',
                            '1',
                            'multi',
                            'shub://',
                            %w[shub://]
                          ),
                          StepParameter.new(
                            'container_name',
                            'Container Name',
                            'Name of the container in the following form: user/container_name',
                            '2',
                            'multi',
                            'validation_container',
                            %w[validation_container]
                          ),
                          StepParameter.new(
                            'container_tag',
                            'Tag',
                            'Tag of the selected container',
                            '3',
                            'multi',
                            'latest',
                            %w[latest]
                          ),
                          StepParameter.new(
                            'sleep_time',
                            'Sleep time',
                            'The time of the eternal sleep',
                            '4',
                            'multi',
                            '1',
                            %w[1 30 60 300 600]
                          )
                        ]),
    RimrockStep.new('validation_stage_out_step',
                    'process-eu/validation_stage_out',
                    'validation_stage_out_script.sh.erb', [:validation_2_type], []),
    StagingInStep.new('staging_in_step',
                      [
                        StepParameter.new(
                          'src_host',
                          'Source Host',
                          'Descriptions placeholder',
                          '0',
                          'multi',
                          'data03.process-project.eu',
                          %w[data03.process-project.eu]
                        ),
                        StepParameter.new(
                          'src_path',
                          'Source Path',
                          'Descriptions placeholder',
                          '1',
                          'multi',
                          '/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif',
                          %w[/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif]
                        ),
                        StepParameter.new(
                          'dest_host',
                          'Destination Host',
                          'Descriptions placeholder',
                          '2',
                          'multi',
                          'pro.cyfronet.pl',
                          %w[pro.cyfronet.pl]
                        ),
                        StepParameter.new(
                          'dest_path',
                          'Destination Path',
                          'Descriptions placeholder',
                          '3',
                          'multi',
                          '/net/archive/groups/plggprocess/Mock/test_staging',
                          %w[/net/archive/groups/plggprocess/Mock/test_staging]
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
                        [],
                        [
                          StepParameter.new(
                            'hpc',
                            'HPC',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Prometheus',
                            %w[Prometheus]
                          ),
                          StepParameter.new(
                            'registry_url',
                            'Registry url',
                            'Singularity registry which contains containers',
                            '1',
                            'multi',
                            'shub://',
                            %w[shub://]
                          ),
                          StepParameter.new(
                            'container_name',
                            'Container Name',
                            'Name of the container in the following form: user/container_name',
                            '2',
                            'multi',
                            'vsoch/hello-world',
                            %w[vsoch/hello-world]
                          ),
                          StepParameter.new(
                            'container_tag',
                            'Tag',
                            'Tag of the selected container',
                            '3',
                            'multi',
                            'latest',
                            %w[latest]
                          )
                        ]),
    SingularityStep.new('medical_step',
                        [],
                        [
                          StepParameter.new(
                            'hpc',
                            'HPC',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Prometheus',
                            %w[Prometheus]
                          ),
                          StepParameter.new(
                            'registry_url',
                            'Registry url',
                            'Singularity registry which contains containers',
                            '1',
                            'multi',
                            'shub://',
                            %w[shub://]
                          ),
                          StepParameter.new(
                            'container_name',
                            'Container Name',
                            'Name of the container in the following form: user/container_name',
                            '2',
                            'multi',
                            'maragraziani/ucdemo',
                            %w[maragraziani/ucdemo]
                          ),
                          StepParameter.new(
                            'container_tag',
                            'Tag',
                            'Tag of the selected container',
                            '3',
                            'multi',
                            '0.1',
                            %w[0.1]
                          )
                        ]),
    SingularityStep.new('lofar_step',
                        [],
                        [
                          StepParameter.new(
                            'hpc',
                            'HPC',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Prometheus',
                            %w[Prometheus]
                          ),
                          StepParameter.new(
                            'registry_url',
                            'Registry url',
                            'Singularity registry which contains containers',
                            '1',
                            'multi',
                            'shub://',
                            %w[shub://]
                          ),
                          StepParameter.new(
                            'container_name',
                            'Container Name',
                            'Name of the container in the following form: user/container_name',
                            '2',
                            'multi',
                            'lofar/lofar_container',
                            %w[lofar/lofar_container]
                          ),
                          StepParameter.new(
                            'container_tag',
                            'Tag',
                            'Tag of the selected container',
                            '3',
                            'multi',
                            'latest',
                            %w[latest]
                          ),
                          StepParameter.new(
                            'visibility_id',
                            'LOFAR Visibility ID',
                            'LOFAR visibility identifier',
                            '4',
                            'string',
                            ''
                          ),
                          StepParameter.new(
                            'avg_freq_step',
                            'Average frequency step',
                            'Corresponds to .freqstep in NDPPP or demixer.freqstep',
                            '5',
                            'integer',
                            2
                          ),
                          StepParameter.new(
                            'avg_time_step',
                            'Average time step',
                            'Corresponds to .timestep in NDPPP or demixer.timestep',
                            '6',
                            'integer',
                            4
                          ),
                          StepParameter.new(
                            'do_demix',
                            'Perform demixer',
                            'If true then demixer instead of average is performed',
                            '7',
                            'boolean',
                            true
                          ),
                          StepParameter.new(
                            'demix_freq_step',
                            'Demixer frequency step',
                            'Corresponds to .demixfreqstep in NDPPP',
                            '8',
                            'integer',
                            2
                          ),
                          StepParameter.new(
                            'demix_time_step',
                            'Demixer time step',
                            'Corresponds to .demixtimestep in NDPPP',
                            '9',
                            'integer',
                            2
                          ),
                          StepParameter.new(
                            'demix_sources',
                            'Demixer sources',
                            '',
                            '10',
                            'multi',
                            'CasA',
                            %w[CasA other]
                          ),
                          StepParameter.new(
                            'select_nl',
                            'Use NL stations only',
                            'If true then only Dutch stations are selected',
                            '11',
                            'boolean',
                            true
                          ),
                          StepParameter.new(
                            'parset',
                            'Parameter set',
                            '',
                            '12',
                            'multi',
                            'lba_npp',
                            %w[lba_npp other]
                          )
                        ]),
    SingularityStep.new('agrocopernicus_step',
                        ['input.csv'],
                        [
                          StepParameter.new(
                            'hpc',
                            'HPC',
                            'Computational resource pool used to execute the computation',
                            '0',
                            'multi',
                            'Prometheus',
                            %w[Prometheus]
                          ),
                          StepParameter.new(
                            'registry_url',
                            'Registry url',
                            'Singularity registry which contains containers',
                            '1',
                            'multi',
                            'shub://',
                            %w[shub://]
                          ),
                          StepParameter.new(
                            'container_name',
                            'Container Name',
                            'Name of the container in the following form: user/container_name',
                            '2',
                            'multi',
                            'vsoch/hello-world',
                            %w[vsoch/hello-world]
                          ),
                          StepParameter.new(
                            'container_tag',
                            'Tag',
                            'Tag of the selected container',
                            '3',
                            'multi',
                            'latest',
                            %w[latest]
                          ),
                          StepParameter.new(
                            'irrigation',
                            'Irrigation',
                            '',
                            '4',
                            'boolean',
                            'true'
                          ),
                          StepParameter.new(
                            'seeding_date',
                            'Seeding date',
                            '',
                            '5',
                            'multi',
                            '-15 days',
                            ['-15 days', 'original', '+15 days']
                          ),
                          StepParameter.new(
                            'nutrition_factor',
                            'Nutrition factor',
                            '',
                            '6',
                            'multi',
                            '0.25',
                            ['0.25', '0.45', '0.60']
                          ),
                          StepParameter.new(
                            'Phenology_factor',
                            'Phenology factor',
                            '',
                            '7',
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
