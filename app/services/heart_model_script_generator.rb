# frozen_string_literal: true
class HeartModelScriptGenerator < ComputationScriptGenerator
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
      cp -r $PLG_GROUPS_STORAGE/plggeurvalve/0DModel/Linx64 .

      ## Copy estimated patient-specific parameters
      #{stage_in_file '0DModel_input.csv'}
    STAGEIN
  end

  def job_script
    <<~SCRIPT
      module load plgrid/apps/matlab/R2016b
      matlab -nojvm -r "addpath('$PLG_GROUPS_STORAGE/plggeurvalve/0DModel');op=Launch0D(0,'0DModel_input.csv');disp(op);exit;"
    SCRIPT
  end

  def stage_out
    <<~STAGEOUT
      #{stage_out_file('Outfile.csv')}
    STAGEOUT
  end
end
