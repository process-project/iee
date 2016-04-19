class ComputationsController < ApplicationController

  def create
    # invoke MK service here
    params = create_params
    params[:user_id] = current_user.id
    params[:script] = 'vapor_script.sh'
    @computation = Computation.create(params)
    redirect_to controller: 'patients', action: 'show', id: params[:patient_id], notice: 'Computation submitted'
  end

  private

  def create_params
    params.require(:computation).permit(:patient_id)
  end

  def script

    #see https://infinum.co/the-capsized-eight/articles/multiline-strings-ruby-2-3-0-the-squiggly-heredoc
    <<~SCRIPT
      #!/bin/bash -l
      SBATCH -J eurvalve_4548
      #SBATCH -N 1
      #SBATCH --ntasks-per-node=24
      #SBATCH --time=00:15:00
      #SBATCH -A eurvalve2
      #SBATCH -p plgrid

      CASE_DIR=$PLG_GROUPS_STORAGE/plggeurvalve/production/4548

      ## Change to the directory where sbatch was called
      cd $SCRATCHDIR

      ## Copy the template file structure over
      cp $PLG_GROUPS_STORAGE/plggeurvalve/template/* .

      ## Copy both fluid and structure files for the given case
      cp $CASE_DIR/fluidFlow.cas .
      cp $CASE_DIR/structural_vent.dat .

      ## Run the script
      ./run_coupled_bashscript.sh

      ## Copy output back
      OUT_FILE_1=`ls -t FluidFlow/fluidFlow-1-* | head -1`
      OUT_FILE_2=`ls -t FluidFlow/fluidFlow-1-* | head -2 | tail -1`
      cp $OUT_FILE_1 $CASE_DIR/
      cp $OUT_FILE_2 $CASE_DIR/
    SCRIPT
  end

end