class ComputationsController < ApplicationController
  def show
    @computation = Computation.find(params[:id])

    render partial: 'patients/computation',
           layout: false,
           object: @computation
  end

  def create
    params[:script] = 'vapor_script.sh'
    @computation = Computation.create(
      create_params.merge(
        user: current_user,
        script: script
      )
    )
    Rimrock::StartJob.perform_later @computation
    redirect_to @computation.patient, notice: 'Computation submitted'
  end

  private

  def create_params
    params.require(:computation).permit(:patient_id)
  end

  def patient
    @patient ||= Patient.find(params[:computation][:patient_id])
  end

  def script
    #see https://infinum.co/the-capsized-eight/articles/multiline-strings-ruby-2-3-0-the-squiggly-heredoc
    <<~SCRIPT
      #!/bin/bash -l
      #SBATCH -N 1
      #SBATCH --ntasks-per-node=24
      #SBATCH --time=00:15:00
      #SBATCH -A eurvalve2
      #SBATCH -p plgrid

      CASE_DIR=$PLG_GROUPS_STORAGE/plggeurvalve/#{Rails.env}/#{patient.case_number}

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
