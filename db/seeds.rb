# frozen_string_literal: true

case Rails.env
when 'developement'
  # require 'seeds_developement'
  admin = User.find_by(email: 'admin@host.domain')
  admin ||= User.create(first_name: 'admin', last_name: 'admin', email: 'admin@host.domain',
                        password: 'admin123', password_confirmation: 'admin123', state: :approved)

  %w[admin supervisor].map do |role_name|
    group = Group.find_or_initialize_by(name: role_name)
    group.user_groups.build(user: admin, owner: true)
    group.save!
  end
end

script = <<~CODE
  #!/bin/bash -l
  #SBATCH -N 1
  #SBATCH --ntasks-per-node=1
  #SBATCH --time=00:05:00
  #SBATCH -A process1
  #SBATCH -p plgrid-testing
  #SBATCH --output /net/archive/groups/plggprocess/Mock/slurm_outputs/slurm-%%j.out
  #SBATCH --error /net/archive/groups/plggprocess/Mock/slurm_outputs/slurm-%%j.err

  ## Running container using singularity
  module load plgrid/tools/singularity/stable

  cd $SCRATCHDIR

  singularity pull --name container.simg %<registry_url>s%<container_name>s:%<container_tag>s
  singularity run container.simg

  echo %<echo_message>s
CODE

ssbp = SingularityScriptBlueprint.create!(container_name: 'vsoch/hello-world',
                                          container_tag: 'latest',
                                          hpc: 'Prometheus',
                                          script_blueprint: script)

ssbp.step_parameters = [
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
                            'echo_message',
                            'Echo Message',
                            'Example message for the container to echo at the end of the execution',
                            '4',
                            'string',
                            ''
                          )
                        ]

script = <<~CODE
  #!/bin/bash
  #SBATCH -A process1gpu
  #SBATCH -p plgrid-gpu
  #SBATCH -N 2
  #SBATCH -n 24
  #SBATCH --gres=gpu:2
  #SBATCH --time 8:00:00
  #SBATCH --job-name UC1_test
  #SBATCH --output /net/archive/groups/plggprocess/UC1/slurm_outputs/uc1-pipeline-log-%%J.txt

  module load plgrid/tools/singularity/stable

  singularity exec --nv -B /net/archive/groups/plggprocess/UC1/data/:/mnt/data/,/net/archive/groups/plggprocess/UC1/external_code/:/mnt/external_code/,/net/archive/groups/plggprocess/UC1/run_scripts/:/mnt/run_scripts /net/archive/groups/plggprocess/UC1/funny_cos_working.img /mnt/run_scripts/runscript.sh 4
CODE

ssbp = SingularityScriptBlueprint.create!(container_name: 'maragraziani/ucdemo',
                                          container_tag: '0.1',
                                          hpc: 'Prometheus',
                                          script_blueprint: script)

ssbp.step_parameters = [
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
                        ]

script = <<~CODE
  #!/bin/bash
  #SBATCH --partition plgrid-short
  #SBATCH -A process1
  #SBATCH --nodes 1
  #SBATCH --ntasks 24
  #SBATCH --time 0:59:59
  #SBATCH --job-name UC2_test
  #SBATCH --output /net/archive/groups/plggprocess/UC2/slurm_outputs/uc1-pipeline-log-%%J.txt
  #SBATCH --error /net/archive/groups/plggprocess/UC2/slurm_outputs/uc1-pipeline-log-%%J.err

  mkdir /net/archive/groups/plggprocess/UC2/container_testing/test_$SLURM_JOB_ID

  sed -e "s/\\$SLURM_JOB_ID/$SLURM_JOB_ID/" /net/archive/groups/plggprocess/UC2/container_testing/pipeline_testing.template > /net/archive/groups/plggprocess/UC2/container_testing/pipeline_testing.cfg

  module load plgrid/tools/singularity/stable
  singularity exec -B /net/archive/groups/plggprocess/UC2/container_testing/ /net/archive/groups/plggprocess/UC2/containers/centos_lofar.simg genericpipeline.py -d -c /net/archive/groups/plggprocess/UC2/container_testing/pipeline_testing.cfg /net/archive/groups/plggprocess/UC2/container_testing/Pre-Facet-Calibrator.parset

  tar -cf /net/archive/groups/plggprocess/UC2/container_testing/test_$SLURM_JOB_ID.tar /net/archive/groups/plggprocess/UC2/container_testing/test_$SLURM_JOB_ID

  <%%= stage_out '/net/archive/groups/plggprocess/UC2/container_testing/test_$SLURM_JOB_ID.tar' %%>
CODE

ssbp = SingularityScriptBlueprint.create!(container_name: 'lofar/lofar_container',
                                   container_tag: 'latest',
                                   hpc: 'Prometheus',
                                   script_blueprint: script)
ssbp.step_parameters = [
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
                        ]


### Agrocopernicus:
script = <<~CODE
  agrocopernicus placeholder
CODE

ssbp = SingularityScriptBlueprint.create!(container_name: 'agrocopernicus placeholder',
                                         container_tag: 'agrocopernicus placeholder',
                                         hpc: 'agrocopernicus placeholder',
                                         script_blueprint: script)
ssbp.step_parameters = [                       # [
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
                        ]