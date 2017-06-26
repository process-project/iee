# frozen_string_literal: true
module ScriptGenerator
  class HeartModel < ScriptGenerator::Computation
    private

    def header
      <<~HEADER
        #!/bin/bash -l
        #SBATCH -N 1
        #SBATCH --ntasks-per-node=1
        #SBATCH --time=00:02:00
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
        ## Copy the required compiled library file structure over
        cp -r $PLG_GROUPS_STORAGE/plggeurvalve/0dmodel-master-5f563eaea47ed363dc9378447ba39b870884f1a2/model/Linx64 .

        ## Copy estimated patient-specific parameters
        #{stage_in_file pipeline.data_file(:estimated_parameters), '0DModel_input.csv'}
      STAGEIN
    end

    def job_script
      <<~SCRIPT
        module load plgrid/apps/matlab/R2016b
        matlab -r "addpath('$PLG_GROUPS_STORAGE/plggeurvalve/0dmodel-master-5f563eaea47ed363dc9378447ba39b870884f1a2/model');op=Launch0D(-1,'0DModel_input.csv');disp(op);exit;"
        cp Flow.png /net/people/plgkasztelnik/
      SCRIPT
    end

    def stage_out
      <<~STAGEOUT
        #{stage_out_file('Outfile.csv')}
        #{stage_out_file('Flow.png')}
        #{stage_out_file('Press.png')}
        #{stage_out_file('PVol.png')}
        #{stage_out_file('Vol.png')}
      STAGEOUT
    end
  end
end
