# frozen_string_literal: true
# rubocop:disable all

# adding script blueprints
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

         singularity pull --name container.simg %{registry_url}%{container_name}:%{tag}
         singularity run container.simg
         CODE

SingularityScriptBlueprint.create(container_name: 'vsoch/hello-world',
                                  tag: 'latest',
                                  hpc: 'Prometheus',
                                  available_options: '',
                                  script_blueprint: script)

script = <<~CODE
         #!/bin/bash
         #SBATCH -A process1
         #SBATCH -p plgrid-testing
         #SBATCH -N 1
         #SBATCH -n 24
         #SBATCH --time 0:59:00
         #SBATCH --job-name UC1_test
         #SBATCH --output /net/archive/groups/plggprocess/UC1/slurm_outputs/uc1-pipeline-log-%%J.txt

         module load plgrid/tools/singularity/stable

         singularity exec --nv -B /net/archive/groups/plggprocess/UC1/data/:/mnt/data/,/net/archive/groups/plggprocess/UC1/external_code/:/mnt/external_code/,/net/archive/groups/plggprocess/UC1/run_scripts/:/mnt/run_scripts /net/archive/groups/plggprocess/UC1/funny_cos_working.img /mnt/run_scripts/runscript.sh
         CODE

SingularityScriptBlueprint.create(container_name: 'maragraziani/ucdemo',
                                  tag: '0.1',
                                  hpc: 'Prometheus',
                                  available_options: '',
                                  script_blueprint: script)
