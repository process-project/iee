# frozen_string_literal: true
class ComputationScriptGenerator
  def initialize(patient, user)
    @patient = patient
    @user = user
  end

  def script
    <<~SCRIPT
      #!/bin/bash -l
      #SBATCH -N 1
      #SBATCH --ntasks-per-node=24
      #SBATCH --time=00:15:00
      #SBATCH -A eurvalve2
      #SBATCH -p plgrid

      ## Change to the directory where sbatch was called
      cd $SCRATCHDIR

      ## Copy the template file structure over
      cp $PLG_GROUPS_STORAGE/plggeurvalve/template/* .

      #{stage_in}

      ## Run the script
      ./run_coupled_bashscript.sh

      ## Copy output back
      cd FluidFlow
      OUT_FILE_1=`ls -t fluidFlow-1-* | head -1`
      OUT_FILE_2=`ls -t fluidFlow-1-* | head -2 | tail -1`

      #{stage_out_file('$OUT_FILE_1')}
      #{stage_out_file('$OUT_FILE_2')}
    SCRIPT
  end

  private

  def stage_in
    <<~STAGEIN
      ## Copy both fluid and structure files for the given case
      #{stage_in_file 'fluidFlow.cas'}
      #{stage_in_file 'structural_vent.dat'}
    STAGEIN
  end

  def stage_in_file(filename)
    if synchronizer.class == WebdavDataFileSynchronizer
      "curl -H \"Authorization: Bearer #{@user.token}\""\
        " \"#{synchronizer.computation_file_handle(filename)}\""\
        " >> \"$SCRATCHDIR/#{filename}\""
    else
      "cp #{synchronizer.computation_file_handle(filename)} $SCRATCHDIR"
    end
  end

  def stage_out_file(filename)
    if synchronizer.class == WebdavDataFileSynchronizer
      "curl -X PUT --data @#{filename}"\
        " -H \"Content-Type:application/octet-stream\" -H \"Authorization: Bearer #{@user.token}\""\
        " \"#{synchronizer.computation_file_handle(filename)}\""
    else
      "cp #{filename} #{synchronizer.computation_file_handle('')}"
    end
  end

  def synchronizer
    @synchronizer || DataFile.synchronizer_class.new(@patient, @user)
  end
end
