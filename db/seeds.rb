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
  #SBATCH -N %<nodes>s
  #SBATCH --ntasks-per-node=%<cpus>s
  #SBATCH --time=00:05:00
  #SBATCH -A process1
  #SBATCH -p %<partition>s
  #SBATCH --job-name mock_container_step
  #SBATCH --output /net/archive/groups/plggprocess/Mock/slurm_outputs/slurm-%%j.out
  #SBATCH --error /net/archive/groups/plggprocess/Mock/slurm_outputs/slurm-%%j.err

  ## Running container using singularity
  module load plgrid/tools/singularity/stable

  cd $SCRATCHDIR

  singularity pull --name container.simg shub://%<container_name>s:%<container_tag>s
  singularity run container.simg

  echo '%<echo_message>s'

  rm container.simg
CODE

ssbp = SingularityScriptBlueprint.create!(container_name: 'vsoch/hello-world',
                                          container_tag: 'latest',
                                          hpc: 'Prometheus',
                                          script_blueprint: script)

ssbp.step_parameters = [
  StepParameter.new(
    'nodes',
    'Nodes',
    'Number of execution nodes',
    0,
    'integer',
    1
  ),
  StepParameter.new(
    'cpus',
    'CPUs',
    'Number of CPU per execution node',
    0,
    'multi',
    '1',
    %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
  ),
  StepParameter.new(
    'partition',
    'Partition',
    'Prometheus execution partition',
    0,
    'multi',
    'plgrid-testing',
    %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
  ),
  StepParameter.new(
    'echo_message',
    'Echo Message',
    'Example message for the container to echo at the end of the execution',
    0,
    'string',
    ''
  )
]

ssbp = SingularityScriptBlueprint.create!(container_name: 'vsoch/hello-world',
                                          container_tag: 'latest',
                                          hpc: 'SuperMUC',
                                          script_blueprint: script)

ssbp.step_parameters = [
  StepParameter.new(
    'echo_message',
    'Echo Message',
    'Example message for the container to echo at the end of the execution',
    0,
    'multi',
    ''
  )
]

script = <<~CODE
  #!/bin/bash
  #SBATCH -A process1gpu
  #SBATCH -p %<partition>s
  #SBATCH -N %<nodes>s
  #SBATCH -n %<cpus>s
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
    'nodes',
    'Nodes',
    'Number of execution nodes',
    0,
    'integer',
    1
  ),
  StepParameter.new(
    'cpus',
    'CPUs',
    'Number of CPU per execution node',
    0,
    'multi',
    '1',
    %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
  ),
  StepParameter.new(
    'partition',
    'Partition',
    'Prometheus execution partition',
    0,
    'multi',
    'plgrid-gpu',
    %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
  )
]

script = <<~CODE
  #!/bin/bash
  #SBATCH --partition %<partition>s
  #SBATCH -A process1
  #SBATCH --nodes %<nodes>s
  #SBATCH --ntasks %<cpus>s
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
    'nodes',
    'Nodes',
    'Number of execution nodes',
    0,
    'integer',
    1
  ),
  StepParameter.new(
    'cpus',
    'CPUs',
    'Number of CPU per execution node',
    0,
    'multi',
    '1',
    %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
  ),
  StepParameter.new(
    'partition',
    'Partition',
    'Prometheus execution partition',
    0,
    'multi',
    'plgrid-short',
    %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
  ),
  StepParameter.new(
    'visibility_id',
    'LOFAR Visibility ID',
    'LOFAR visibility identifier',
    0,
    'string',
    ''
  ),
  StepParameter.new(
    'avg_freq_step',
    'Average frequency step',
    'Corresponds to .freqstep in NDPPP or demixer.freqstep',
    0,
    'integer',
    2
  ),
  StepParameter.new(
    'avg_time_step',
    'Average time step',
    'Corresponds to .timestep in NDPPP or demixer.timestep',
    0,
    'integer',
    4
  ),
  StepParameter.new(
    'do_demix',
    'Perform demixer',
    'If true then demixer instead of average is performed',
    0,
    'boolean',
    true
  ),
  StepParameter.new(
    'demix_freq_step',
    'Demixer frequency step',
    'Corresponds to .demixfreqstep in NDPPP',
    0,
    'integer',
    2
  ),
  StepParameter.new(
    'demix_time_step',
    'Demixer time step',
    'Corresponds to .demixtimestep in NDPPP',
    0,
    'integer',
    2
  ),
  StepParameter.new(
    'demix_sources',
    'Demixer sources',
    '',
    0,
    'multi',
    'CasA',
    %w[CasA other]
  ),
  StepParameter.new(
    'select_nl',
    'Use NL stations only',
    'If true then only Dutch stations are selected',
    0,
    'boolean',
    true
  ),
  StepParameter.new(
    'parset',
    'Parameter set',
    '',
    0,
    'multi',
    'lba_npp',
    %w[lba_npp other]
  )
]

### Agrocopernicus:
script = <<~CODE
  agrocopernicus placeholder
CODE

ssbp = SingularityScriptBlueprint.create!(container_name: 'agrocopernicus_placeholder_container',
                                          container_tag: 'agrocopernicus_placeholder_tag',
                                          hpc: 'Prometheus',
                                          script_blueprint: script)
ssbp.step_parameters = [
  StepParameter.new(
    'irrigation',
    'Irrigation',
    '',
    0,
    'boolean',
    'true'
  ),
  StepParameter.new(
    'seeding_date',
    'Seeding date',
    '',
    0,
    'multi',
    '-15 days',
    ['-15 days', 'original', '+15 days']
  ),
  StepParameter.new(
    'nutrition_factor',
    'Nutrition factor',
    '',
    0,
    'multi',
    '0.25',
    ['0.25', '0.45', '0.60']
  ),
  StepParameter.new(
    'Phenology_factor',
    'Phenology factor',
    '',
    0,
    'multi',
    '0.6',
    ['0.6', '0.8', '1.0', '1.2']
  )
]
