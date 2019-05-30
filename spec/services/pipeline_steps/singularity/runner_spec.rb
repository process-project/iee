# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Singularity::Runner do
  let(:updater) { instance_double(ComputationUpdater, call: true) }

  let(:singularity_pipeline) do
    create(:pipeline, flow: 'singularity_placeholder_pipeline')
  end

  let(:computation) do
    create(:computation,
           pipeline_step: 'placeholder_step')
  end

  let(:singularity_computation) do
    create(:singularity_computation,
           pipeline: pipeline,
           pipeline_step: 'singularity_placeholder_step')
  end

  let(:container_name) { 'vsoch/hello-world' }
  let(:container_tag) { 'latest' }
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

    singularity pull --name container.simg %<registry_url>s%<container_name>s:%<tag>s
    singularity run container.simg
  CODE

  SingularityScriptBlueprint.create!(container_name: 'vsoch/hello-world',
                                     container_tag: 'latest',
                                     hpc: 'Prometheus',
                                     script_blueprint: script)

  subject do
    described_class.new(computation,
                        updater: double(new: updater))
  end

  context 'container step running' do
    # it_behaves_like 'runnable step'

    it 'starts a Rimrock job' do
      expect(Rimrock::StartJob).to receive(:perform_later)

      subject.call
    end

    it 'creates computation with script returned by singularity script generator' do
      # subject.call

      # expect(computation.script).to include container_registry.registry_url +
      #                                       container_name +
      #                                       ':' +
      #                                       container_tag
    end

    it 'set job_id to null while restarting computation' do
      computation.update_attributes(job_id: 'some_id')

      subject.call

      expect(computation.job_id).to be_nil
    end
  end
end
