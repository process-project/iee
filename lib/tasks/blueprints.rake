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

    common_chmod_script_part_out =
      'chmod -R g+w %<uc_root>s/pipelines/%<pipeline_hash>s/out/*' + "\n"
    common_chmod_script_part_workdir =
      'chmod -R g+w %<uc_root>s/pipelines/%<pipeline_hash>s/workdir/*' + "\n"

    # Testing container 1 for the full test pipeline (LOBCDER staging steps compatible)
    testing_container_1_script_part =
      '%<uc_root>s/containers/testing_container_1.sif operation=%<operation>s'
    script = common_script_part + testing_container_1_script_part + "\n" +
             common_chmod_script_part_out +
             common_chmod_script_part_workdir

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
    script = common_script_part + testing_container_2_script_part + "\n" +
             common_chmod_script_part_out +
             common_chmod_script_part_workdir

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
    script = <<~CODE
      #!/bin/bash -l
      #SBATCH --partition %<partition>s
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH --nodes %<nodes>s
      #SBATCH --ntasks %<cpus>s
      #SBATCH --time %<time>s:00:00
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

    script = script + "\n" + common_chmod_script_part_out +
             common_chmod_script_part_workdir

    ssbp = SingularityScriptBlueprint.create!(container_name: 'factor-iee.sif',
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
        default: 'plgrid-long',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'time',
        name: 'Time',
        description: 'Number of hours',
        rank: 0,
        datatype: 'integer',
        default: 168
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

    # Container for testing UC2 LOFAR use case
    script = <<~CODE
      #!/bin/bash -l
      #SBATCH --partition %<partition>s
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH --nodes %<nodes>s
      #SBATCH --ntasks %<cpus>s
      #SBATCH --time %<time>s:00:00
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
      %<uc_root>s/containers/uc2_factor_fast.sif \\
      calms=%<calms>s tarms=%<tarms>s datadir=%<datadir>s factordir=%<factordir>s workdir=%<workdir>s \\
    CODE

    script = script + "\n" + common_chmod_script_part_out +
             common_chmod_script_part_workdir

    ssbp = SingularityScriptBlueprint.create!(container_name: 'uc2_factor_fast.sif',
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
        default: 'plgrid-long',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'time',
        name: 'Time',
        description: 'Number of hours',
        rank: 0,
        datatype: 'integer',
        default: 11
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

    # workaround step for testing UC2 LOFAR use case
    script = <<~CODE
      #!/bin/bash -l
      #SBATCH --partition %<partition>s
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH --nodes %<nodes>s
      #SBATCH --ntasks %<cpus>s
      #SBATCH --time %<time>s:00:00
      #SBATCH --job-name UC2_test
      #SBATCH --output %<uc_root>s/slurm_outputs/uc2-pipeline-log-%%J.txt
      #SBATCH --error %<uc_root>s/slurm_outputs/uc2-pipeline-log-%%J.err

      module load plgrid/tools/singularity/stable
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp
      mkdir -p %<uc_root>s/pipelines/%<pipeline_hash>s/in
      mkdir -p %<uc_root>s/pipelines/%<pipeline_hash>s/workdir
      mkdir -p %<uc_root>s/pipelines/%<pipeline_hash>s/out

      cp %<uc_root>s/%<src_path>s/* %<uc_root>s/pipelines/%<pipeline_hash>s/in

      singularity run \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/in:/mnt/in \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/workdir:/mnt/workdir \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/out:/mnt/out \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp:/tmp \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp:/var/tmp \\
      %<uc_root>s/containers/uc2_factor_fast.sif \\
      calms=%<calms>s tarms=%<tarms>s datadir=%<datadir>s factordir=%<factordir>s workdir=%<workdir>s \\

      cp %<uc_root>s/pipelines/%<pipeline_hash>s/out/* %<uc_root>s/%<dest_path>s

      rm -rf $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s
      rm -rf %<uc_root>s/pipelines/%<pipeline_hash>s
    CODE

    ssbp = SingularityScriptBlueprint.create!(container_name: 'workaround_uc2_factor_fast.sif',
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
        default: 'plgrid-long',
        values: %w[plgrid-testing plgrid plgrid-short plgrid-long plgrid-gpu plgrid-large]
      ),
      StepParameter.new(
        label: 'time',
        name: 'Time',
        description: 'Number of hours',
        rank: 0,
        datatype: 'integer',
        default: 11
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
      ),
      StepParameter.new(
        label: 'src_path',
        name: 'Source path',
        description: 'The source path of the input',
        rank: 0,
        datatype: 'string',
        default: 'testing_data_backup'
      ),
      StepParameter.new(
        label: 'dest_path',
        name: 'Destination path',
        description: 'The destination path of the output',
        rank: 0,
        datatype: 'string',
        default: 'WORKAROUND_LOFAR_RESULTS'
      )
    ]

    # workaround testing singularity step 1
    script = <<~CODE
      #!/bin/bash -l
      #SBATCH -N %<nodes>s
      #SBATCH --ntasks-per-node=%<cpus>s
      #SBATCH --time=00:05:00
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH -p %<partition>s
      #SBATCH --job-name testing_container_step
      #SBATCH --output %<uc_root>s/slurm_outputs/slurm-%%j.out
      #SBATCH --error %<uc_root>s/slurm_outputs/slurm-%%j.err

      # Load singularity
      module load plgrid/tools/singularity/stable

      # Directory builder workaround
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp
      mkdir -p $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp
      mkdir -p %<uc_root>s/pipelines/%<pipeline_hash>s/in
      mkdir -p %<uc_root>s/pipelines/%<pipeline_hash>s/workdir
      mkdir -p %<uc_root>s/pipelines/%<pipeline_hash>s/out

      # Staging in step workaround
      cp %<uc_root>s/%<src_path>s/* %<uc_root>s/pipelines/%<pipeline_hash>s/in

      # Singularity step run
      singularity run \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/in:/mnt/in \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/workdir:/mnt/workdir \\
      -B %<uc_root>s/pipelines/%<pipeline_hash>s/out:/mnt/out \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/tmp:/tmp \\
      -B $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s/var_tmp:/var/tmp \\
      %<uc_root>s/containers/testing_container_1.sif operation=%<operation>s

      # Staging out step workaround
      cp -r %<uc_root>s/pipelines/%<pipeline_hash>s/out/* %<uc_root>s/%<dest_path>s

      # Cleanup step workaround
      rm -rf $SCRATCH/%<uc_root>s/pipelines/%<pipeline_hash>s
      rm -rf %<uc_root>s/pipelines/%<pipeline_hash>s
    CODE

    ssbp = SingularityScriptBlueprint.create!(container_name: 'workaround_testing_container_1.sif',
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
        label: 'operation',
        name: 'Operation',
        description: 'Operation to perform',
        rank: 0,
        datatype: 'multi',
        default: 'add',
        values: %w[add subtract multiply divide]
      ),
      StepParameter.new(
        label: 'src_path',
        name: 'Source path',
        description: 'The source path of the input',
        rank: 0,
        datatype: 'string',
        default: 'UC_test/input_for_pipeline'
      ),
      StepParameter.new(
        label: 'dest_path',
        name: 'Destination path',
        description: 'The destination path of the output',
        rank: 0,
        datatype: 'string',
        default: 'UC_test/output_for_pipeline'
      )
    ]
  end
end
