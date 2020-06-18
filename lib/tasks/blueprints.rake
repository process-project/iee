# frozen_string_literal: true

namespace :blueprints do
  desc 'Seed singularity script blueprints for known pipelines'
  task seed: :environment do
    SingularityScriptBlueprint.destroy_all

    # Common fragments of the test and full test pipeline (LOBCDER staging steps compatible)

    common_script_part = <<~CODE
      #!/bin/bash -l
      #SBATCH -N %<nodes>s
      #SBATCH --ntasks-per-node=%<cpus>s
      #SBATCH --time=00:05:00
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH -p %<partition>s
      #SBATCH --job-name testing_container_step
      #SBATCH --output %<uc_root>s/slurm_outputs/slurm-%%j.out
      #SBATCH --error %<uc_root>s/slurm_outputs/slurm-%%j.err
      # Running container using singularity
      module load plgrid/tools/singularity/stable
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp
      singularity run \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/in:/mnt/in \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/workdir:/mnt/workdir \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/out:/mnt/out \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp:/tmp \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp:/var/tmp \\
    CODE

    common_chmod_script_part = 'chmod -R g+w %<uc_root>s/pipelines/%<pipeline_hash>s' + "\n"

    # Testing container 1 for the full test pipeline (LOBCDER staging steps compatible)
    testing_container_1_script_part =
      '%<uc_root>s/containers/testing_container_1.sif operation=%<operation>s'
    script = common_script_part + testing_container_1_script_part + "\n" + common_chmod_script_part

    ssbp = SingularityScriptBlueprint.create!(container_name: 'testing_container_1.sif',
                                              container_tag: 'whatever_tag_and_it_is_to_remove',
                                              compute_site: ComputeSite.where(name: 'krk').first,
                                              script_blueprint: script)

    ssbp.step_parameters = [
      StepParameter.new(
        label: 'nodes',
        name: 'Nodes',
        description: 'Number of execution nodes',
        rank: 0,
        datatype: 'integer',
        default: 1
      ),
      StepParameter.new(
        label: 'cpus',
        name: 'CPUs',
        description: 'Number of CPU per execution node',
        rank: 0,
        datatype: 'multi',
        default: '1',
        values: %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
      ),
      StepParameter.new(
        label: 'partition',
        name: 'Partition',
        description: 'Prometheus execution partition',
        rank: 0,
        datatype: 'multi',
        default: 'plgrid-testing',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'operation',
        name: 'Operation',
        description: 'Operation to perform',
        rank: 0,
        datatype: 'multi',
        default: 'add',
        values: %w[add subtract multiply divide]
      )
    ]

    # Testing container 2 for the full test pipeline (LOBCDER staging steps compatible)
    testing_container_2_script_part =
      '%<uc_root>s/containers/testing_container_2.sif factor=%<factor>s'
    script = common_script_part + testing_container_2_script_part + "\n" + common_chmod_script_part

    ssbp = SingularityScriptBlueprint.create!(container_name: 'testing_container_2.sif',
                                              container_tag: 'whatever_tag_and_it_is_to_remove',
                                              compute_site: ComputeSite.where(name: 'krk').first,
                                              script_blueprint: script)

    ssbp.step_parameters = [
      StepParameter.new(
        label: 'nodes',
        name: 'Nodes',
        description: 'Number of execution nodes',
        rank: 0,
        datatype: 'integer',
        default: 1
      ),
      StepParameter.new(
        label: 'cpus',
        name: 'CPUs',
        description: 'Number of CPU per execution node',
        rank: 0,
        datatype: 'multi',
        default: '1',
        values: %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
      ),
      StepParameter.new(
        label: 'partition',
        name: 'Partition',
        description: 'Prometheus execution partition',
        rank: 0,
        datatype: 'multi',
        default: 'plgrid-testing',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'factor',
        name: 'Factor',
        description: 'Factor by which the result from previous step will by multiplied',
        rank: 0,
        datatype: 'integer',
        default: 1000
      )
    ]

    # Test container for the Prometheus Compute Site
    script = <<~CODE
      #!/bin/bash -l
      #SBATCH -N %<nodes>s
      #SBATCH --ntasks-per-node=%<cpus>s
      #SBATCH --time=00:05:00
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
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
                                              compute_site: ComputeSite.where(name: 'krk').first,
                                              script_blueprint: script)

    ssbp.step_parameters = [
      StepParameter.new(
        label: 'nodes',
        name: 'Nodes',
        description: 'Number of execution nodes',
        rank: 0,
        datatype: 'integer',
        default: 1
      ),
      StepParameter.new(
        label: 'cpus',
        name: 'CPUs',
        description: 'Number of CPU per execution node',
        rank: 0,
        datatype: 'multi',
        default: '1',
        values: %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
      ),
      StepParameter.new(
        label: 'partition',
        name: 'Partition',
        description: 'Prometheus execution partition',
        rank: 0,
        datatype: 'multi',
        default: 'plgrid-testing',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'echo_message',
        name: 'Echo Message',
        description: 'Example message for the container to echo at the end of the execution',
        rank: 0,
        datatype: 'string',
        default: ''
      )
    ]

    # Test container for the SuperMUC Compute Site
    ssbp = SingularityScriptBlueprint.create!(container_name: 'vsoch/hello-world',
                                              container_tag: 'latest',
                                              compute_site: ComputeSite.where(name: 'lrzdtn').first,
                                              script_blueprint: script)

    ssbp.step_parameters = [
      StepParameter.new(
        label: 'echo_message',
        name: 'Echo Message',
        description: 'Example message for the container to echo at the end of the execution',
        rank: 0,
        datatype: 'string',
        default: ''
      )
    ]

    # Container for the UC1 Medical use case
    script = <<~CODE
      #!/bin/bash
      #SBATCH -A #{Rails.application.config_for('process')['gpu_grant_id']}
      #SBATCH -p %<partition>s
      #SBATCH -N %<nodes>s
      #SBATCH -n %<cpus>s
      #SBATCH --gres=gpu:2
      #SBATCH --time 8:00:00
      #SBATCH --job-name UC1_test
      #SBATCH --output /net/archive/groups/plggprocess/UC1/slurm_outputs/uc1-pipeline-log-%%J.txt

      module load plgrid/tools/singularity/stable

      singularity exec --nv -B /net/archive/groups/plggprocess/UC1/data/:/mnt/data/,\
                               /net/archive/groups/plggprocess/UC1/external_code/:/mnt/external_code/,\
                               /net/archive/groups/plggprocess/UC1/run_scripts/:/mnt/run_scripts \
                               /net/archive/groups/plggprocess/UC1/funny_cos_working.img \
                               /mnt/run_scripts/runscript.sh %<gpus>s
    CODE

    ssbp = SingularityScriptBlueprint.create!(container_name: 'maragraziani/ucdemo',
                                              container_tag: '0.1',
                                              compute_site: ComputeSite.where(name: 'krk').first,
                                              script_blueprint: script)

    ssbp.step_parameters = [
      StepParameter.new(
        label: 'nodes',
        name: 'Nodes',
        description: 'Number of execution nodes',
        rank: 0,
        datatype: 'integer',
        default: 1
      ),
      StepParameter.new(
        label: 'cpus',
        name: 'CPUs',
        description: 'Number of CPU per execution node',
        rank: 0,
        datatype: 'multi',
        default: '1',
        values: %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
      ),
      StepParameter.new(
        label: 'partition',
        name: 'Partition',
        description: 'Prometheus execution partition',
        rank: 0,
        datatype: 'multi',
        default: 'plgrid-gpu',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'gpus',
        name: 'GPUs',
        description: 'Total number of GPUS',
        rank: 0,
        datatype: 'integer',
        default: 1
      )
    ]

    # Container for the UC2 LOFAR use case
    # TODO: update to new version of container (new and old containers work in the same way,
    #  but there are differences in the scripts)
    script = <<~CODE
      #!/bin/bash
      #SBATCH --partition %<partition>s
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH --nodes %<nodes>s
      #SBATCH --ntasks %<cpus>s
      #SBATCH --time 167:59:58
      #SBATCH --job-name UC2_test
      #SBATCH --output %<uc_root>s/slurm_outputs/uc2-pipeline-log-%%J.txt
      #SBATCH --error %<uc_root>s/slurm_outputs/uc2-pipeline-log-%%J.err

      module load plgrid/tools/singularity/stable
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp

      singularity run \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/in:/mnt/in \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/workdir:/mnt/workdir \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/out:/mnt/out \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp:/tmp \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp:/var/tmp \\
      %<uc_root>s/containers/factor-iee.sif \\
      calms=%<calms>s tarms=%<tarms>s datadir=%<datadir>s factordir=%<factordir>s workdir=%<workdir>s \\
    CODE

    script = script + "\n" + common_chmod_script_part

    ssbp = SingularityScriptBlueprint.create!(container_name: 'factor-iee.sif.old',
                                              container_tag: 'latest',
                                              compute_site: ComputeSite.where(name: 'krk').first,
                                              script_blueprint: script)
    ssbp.step_parameters = [
      StepParameter.new(
        label: 'nodes',
        name: 'Nodes',
        description: 'Number of execution nodes',
        rank: 0,
        datatype: 'integer',
        default: 1
      ),
      StepParameter.new(
        label: 'cpus',
        name: 'CPUs',
        description: 'Number of CPU per execution node',
        rank: 0,
        datatype: 'multi',
        default: '24',
        values: %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]
      ),
      StepParameter.new(
        label: 'partition',
        name: 'Partition',
        description: 'Prometheus execution partition',
        rank: 0,
        datatype: 'multi',
        default: 'plgrid',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'calms',
        name: 'Calms',
        description: 'The calms parameter',
        rank: 0,
        datatype: 'string',
        default: '232873'
      ),
      StepParameter.new(
        label: 'tarms',
        name: 'Tarms',
        description: 'The tarms parameter',
        rank: 0,
        datatype: 'string',
        default: '232875'
      ),
      StepParameter.new(
        label: 'datadir',
        name: 'Datadir',
        description: 'The datadir parameter',
        rank: 0,
        datatype: 'string',
        default: '/mnt/in'
      ),
      StepParameter.new(
        label: 'factordir',
        name: 'Factordir',
        description: 'The factordir parameter',
        rank: 0,
        datatype: 'string',
        default: '/mnt/out/factor'
      ),
      StepParameter.new(
        label: 'workdir',
        name: 'Workdir',
        description: 'The workdir parameter',
        rank: 0,
        datatype: 'string',
        default: '/mnt/workdir/test'
      )
    ]

    ### Agrocopernicus:
    script = <<~CODE
      agrocopernicus placeholder
    CODE

    ssbp = SingularityScriptBlueprint.create!(
      container_name: 'agrocopernicus_placeholder_container',
      container_tag: 'agrocopernicus_placeholder_tag',
      compute_site: ComputeSite.where(name: 'krk').first,
      script_blueprint: script
    )

    ssbp.step_parameters = [
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
        label: 'Phenology_factor',
        name: 'Phenology factor',
        description: '',
        rank: 0,
        datatype: 'multi',
        default: '0.6',
        values: ['0.6', '0.8', '1.0', '1.2']
      )
    ]

    # Validation container
    script = <<~CODE
      #!/bin/bash
      #SBATCH --partition plgrid-testing
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH --nodes %<nodes>s
      #SBATCH --ntasks %<containers>s
      #SBATCH --cpus-per-task %<cores_per_container>s
      #SBATCH --mem-per-cpu 5GB
      #SBATCH --time 0:15:00
      #SBATCH --job-name validation_container_test
      #SBATCH --output /net/archive/groups/plggprocess/Mock/slurm_outputs/validation-container-test-log-%%J.txt
      #SBATCH --error /net/archive/groups/plggprocess/Mock/slurm_outputs/validation-container-test-log-%%J.err

      module load plgrid/tools/singularity/stable

      srun singularity run /net/archive/groups/plggprocess/Mock/dummy_container/valcon.simg /bin /bin %<sleep_time>s

      touch validation_container_done.txt

      <%%= stage_out 'validation_container_done.txt' %%>
    CODE

    ssbp = SingularityScriptBlueprint.create!(container_name: 'validation_container',
                                              container_tag: 'latest',
                                              compute_site: ComputeSite.where(name: 'krk').first,
                                              script_blueprint: script)

    ssbp.step_parameters = [
      StepParameter.new(
        label: 'nodes',
        name: 'Nodes',
        description: 'Number of execution nodes',
        rank: 0,
        datatype: 'multi',
        default: '2',
        values: %w[1 2 10]
      ),
      StepParameter.new(
        label: 'containers',
        name: 'Containers',
        description: 'Number of containers',
        rank: 0,
        datatype: 'multi',
        default: '1',
        values: %w[1 2 8 10 40 48 240]
      ),
      StepParameter.new(
        label: 'cores_per_container',
        name: 'Cores per container',
        description: 'Number of cores per container',
        rank: 0,
        datatype: 'multi',
        default: '1',
        values: %w[1 6 24]
      ),
      StepParameter.new(
        label: 'sleep_time',
        name: 'Sleep time',
        description: 'Time in seconds for the container to sleep',
        rank: 0,
        datatype: 'integer',
        default: 1
      )
    ]
  end
end
