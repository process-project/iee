# frozen_string_literal: true

require 'erb'

class SingularityScriptGenerator
  attr_reader :computation

  def initialize(computation, registry_url, container_name)
    @computation = computation
    @registry_url = registry_url
    @container_name = container_name
  end

  def call
    <<~CODE
      #!/bin/bash -l
      #SBATCH -N 1
      #SBATCH --ntasks-per-node=1
      #SBATCH --time=00:05:00
      #SBATCH -A process1
      #SBATCH -p plgrid-testing
      #SBATCH --output /net/archive/groups/plggprocess/Mock/slurm_outputs/slurm-%j.out
      #SBATCH --error /net/archive/groups/plggprocess/Mock/slurm_outputs/slurm-%j.err

      ## Running container using singularity
      module load plgrid/tools/singularity/stable

      cd $SCRATCHDIR

      singularity pull --name container.simg #{@registry_url}#{@container_name} 
      singularity run container.simg
    CODE
  end

end
