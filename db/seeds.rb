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

  touch staging_done.txt
  <%%= stage_out 'staging_done.txt' %%>
CODE

SingularityScriptBlueprint.create!(container_name: 'vsoch/hello-world',
                                   tag: 'latest',
                                   hpc: 'Prometheus',
                                   available_options: '',
                                   script_blueprint: script)

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

SingularityScriptBlueprint.create!(container_name: 'maragraziani/ucdemo',
                                   tag: '0.1',
                                   hpc: 'Prometheus',
                                   available_options: '',
                                   script_blueprint: script)

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

SingularityScriptBlueprint.create!(container_name: 'lofar/lofar_container',
                                   tag: 'latest',
                                   hpc: 'Prometheus',
                                   available_options: '',
                                   script_blueprint: script)

script = <<~CODE
  #!/bin/bash
  #SBATCH --partition plgrid-testing
  #SBATCH -A process1
  #SBATCH --nodes 1
  #SBATCH --ntasks 24
  #SBATCH --time 0:15:00
  #SBATCH --job-name validation_container_test
  #SBATCH --output /net/archive/groups/plggprocess/Mock/slurm_outputs/validation-container-test-log-%%J.txt
  #SBATCH --error /net/archive/groups/plggprocess/Mock/slurm_outputs/validation-container-test-log-%%J.err

  module load plgrid/tools/singularity/stable

  singularity run /net/archive/groups/plggprocess/Mock/dummy_container/valcon.simg /bin /bin %<sleep_time>s

  touch validation_container_done.txt

  <%%= stage_out 'validation_container_done.txt' %%>
CODE

SingularityScriptBlueprint.create!(container_name: 'validation_container',
                                   tag: 'latest',
                                   hpc: 'Prometheus',
                                   available_options: '',
                                   script_blueprint: script)
