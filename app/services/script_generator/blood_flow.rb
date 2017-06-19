# frozen_string_literal: true
module ScriptGenerator
  class BloodFlow < ScriptGenerator::Computation
    private

    def header
      <<~HEADER
        #!/bin/bash -l
        #SBATCH -N 1
        #SBATCH --ntasks-per-node=24
        #SBATCH --time=00:15:00
        #SBATCH -A #{grant_id}
        #SBATCH -p plgrid
        #SBATCH --output /net/archive/groups/plggeurvalve/slurm_outputs/slurm-%j.out
        #SBATCH --error /net/archive/groups/plggeurvalve/slurm_outputs/slurm-%j.err

        ## Change to the directory where sbatch was called
        cd $SCRATCHDIR
      HEADER
    end

    def stage_in
      <<~STAGEIN
        ## Copy the template file structure over
        cp $PLG_GROUPS_STORAGE/plggeurvalve/template/* .

        ## Copy both fluid and structure files for the given case
        #{stage_in_file pipeline.data_file(:fluid_virtual_model), 'fluidFlow.cas'}
        #{stage_in_file pipeline.data_file(:ventricle_virtual_model), 'structural_vent.dat'}
      STAGEIN
    end

    def job_script
      "./run_coupled_bashscript.sh\n"
    end

    def stage_out
      <<~STAGEOUT
        cd FluidFlow
        OUT_FILE_1=`ls -t fluidFlow-1-* | head -1`
        OUT_FILE_2=`ls -t fluidFlow-1-* | head -2 | tail -1`

        #{stage_out_file('$OUT_FILE_1')}
        #{stage_out_file('$OUT_FILE_2')}
      STAGEOUT
    end
  end
end
