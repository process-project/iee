# frozen_string_literal: true

namespace :blueprints do
  desc 'Seed singularity script blueprints for known pipelines'
  task seed: :environment do
    # Testing container for the new architecture (LOBCDER staging steps compatible)
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

      # Running container using singularity
      module load plgrid/tools/singularity/stable

      singularity run \
      -B %<uc_root>s/pipelines/pipeline_hash_1/in:/mnt/in \
      -B %<uc_root>s/pipelines/pipeline_hash_1/workdir:/mnt/workdir \
      -B %<uc_root>s/pipelines/pipeline_hash_1/out:/mnt/out \
      %<uc_root>s/containers/testing_container.sif operation=%<operation>s
    CODE

    ssbp = SingularityScriptBlueprint.create!(container_name: 'testing_container.sif',
                                              container_tag: 'whatever_tag_and_it_is_to_remove',
                                              compute_site: ComputeSite.where(name: :krk.to_s).first,
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
                                              compute_site: ComputeSite.where(name: :krk.to_s).first,
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
                                              compute_site: ComputeSite.where(name: :lrzdtn.to_s).first,
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
                                              compute_site: ComputeSite.where(name: :krk.to_s).first,
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
      #!/bin/bash
      #SBATCH --partition %<partition>s
      #SBATCH -A #{Rails.application.config_for('process')['grant_id']}
      #SBATCH --nodes %<nodes>s
      #SBATCH --ntasks %<cpus>s
      #SBATCH --time 2:00:00
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

    ssbp = SingularityScriptBlueprint.create!(container_name: 'factor-iee.sif',
                                              container_tag: 'latest',
                                              compute_site: ComputeSite.where(name: :krk.to_s).first,
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
        label: 'visibility_id',
        name: 'LOFAR Visibility ID',
        description: 'LOFAR visibility identifier',
        rank: 0,
        datatype: 'string',
        default: '1234'
      ),
      StepParameter.new(
        label: 'avg_freq_step',
        name: 'Average frequency step',
        description: 'Corresponds to .freqstep in NDPPP or demixer.freqstep',
        rank: 0,
        datatype: 'integer',
        default: 2
      ),
      StepParameter.new(
        label: 'avg_time_step',
        name: 'Average time step',
        description: 'Corresponds to .timestep in NDPPP or demixer.timestep',
        rank: 0,
        datatype: 'integer',
        default: 4
      ),
      StepParameter.new(
        label: 'do_demix',
        name: 'Perform demixer',
        description: 'If true then demixer instead of average is performed',
        rank: 0,
        datatype: 'boolean',
        default: true
      ),
      StepParameter.new(
        label: 'demix_freq_step',
        name: 'Demixer frequency step',
        description: 'Corresponds to .demixfreqstep in NDPPP',
        rank: 0,
        datatype: 'integer',
        default: 2
      ),
      StepParameter.new(
        label: 'demix_time_step',
        name: 'Demixer time step',
        description: 'Corresponds to .demixtimestep in NDPPP',
        rank: 0,
        datatype: 'integer',
        default: 2
      ),
      StepParameter.new(
        label: 'demix_sources',
        name: 'Demixer sources',
        description: '',
        rank: 0,
        datatype: 'multi',
        default: 'CasA',
        values: %w[CasA other]
      ),
      StepParameter.new(
        label: 'select_nl',
        name: 'Use NL stations only',
        description: 'If true then only Dutch stations are selected',
        rank: 0,
        datatype: 'boolean',
        default: true
      ),
      StepParameter.new(
        label: 'parset',
        name: 'Parameter set',
        description: '',
        rank: 0,
        datatype: 'multi',
        default: 'lba_npp',
        values: %w[lba_npp other]
      )
    ]

    ### Agrocopernicus:
    script = <<~CODE
      agrocopernicus placeholder
    CODE

    ssbp = SingularityScriptBlueprint.create!(
      container_name: 'agrocopernicus_placeholder_container',
      container_tag: 'agrocopernicus_placeholder_tag',
      compute_site: ComputeSite.where(name: :krk.to_s).first,
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
                                              compute_site: ComputeSite.where(name: :krk.to_s).first,
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
