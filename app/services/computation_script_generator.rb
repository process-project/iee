# frozen_string_literal: true
class ComputationScriptGenerator
  def initialize(patient, user)
    @patient = patient
    @user = user
  end

  def script
    header + stage_in +
      if @patient.virtual_model_ready?
        "./run_coupled_bashscript.sh\n"
      elsif @patient.after_parameter_estimation?
        <<~SCRIPT
          module load plgrid/apps/matlab/R2016b
          matlab -nojvm -r "addpath('$PLG_GROUPS_STORAGE/plggeurvalve/0DModel');op=Launch0D(0,'0DModel_input.csv');disp(op);exit;"
        SCRIPT
      end +
      stage_out
  end

  private

  def stage_in
    if @patient.virtual_model_ready?
      <<~STAGEIN
        ## Copy the template file structure over
        cp $PLG_GROUPS_STORAGE/plggeurvalve/template/* .

        ## Copy both fluid and structure files for the given case
        #{stage_in_file 'fluidFlow.cas'}
        #{stage_in_file 'structural_vent.dat'}
      STAGEIN
    elsif @patient.after_parameter_estimation?
      <<~STAGEIN
        ## Copy the required compiled library file structure over
        cp -r $PLG_GROUPS_STORAGE/plggeurvalve/0DModel/Linx64 .

        ## Copy estimated patient-specific parameters
        #{stage_in_file '0DModel_input.csv'}
      STAGEIN
    end
  end

  def stage_out
    if @patient.virtual_model_ready?
      <<~STAGEOUT
        cd FluidFlow
        OUT_FILE_1=`ls -t fluidFlow-1-* | head -1`
        OUT_FILE_2=`ls -t fluidFlow-1-* | head -2 | tail -1`

        #{stage_out_file('$OUT_FILE_1')}
        #{stage_out_file('$OUT_FILE_2')}
      STAGEOUT
    elsif @patient.after_parameter_estimation?
      <<~STAGEOUT
        #{stage_out_file('Outfile.csv')}
      STAGEOUT
    end
  end

  def header
    <<~HEADER
      #!/bin/bash -l
      #{execution_settings}

      ## Change to the directory where sbatch was called
      cd $SCRATCHDIR
    HEADER
  end

  def execution_settings
    if @patient.virtual_model_ready?
      <<~EXECSETTINGS
        #SBATCH -N 1
        #SBATCH --ntasks-per-node=24
        #SBATCH --time=00:15:00
        #SBATCH -A eurvalve3
        #SBATCH -p plgrid
        #SBATCH --output /net/archive/groups/plggeurvalve/slurm_outputs/slurm-%j.out
        #SBATCH --error /net/archive/groups/plggeurvalve/slurm_outputs/slurm-%j.err
      EXECSETTINGS
    elsif @patient.after_parameter_estimation?
      <<~EXECSETTINGS
        #SBATCH -N 1
        #SBATCH --ntasks-per-node=1
        #SBATCH --time=00:02:00
        #SBATCH -A eurvalve3
        #SBATCH -p plgrid
        #SBATCH --output /net/archive/groups/plggeurvalve/slurm_outputs/slurm-%j.out
        #SBATCH --error /net/archive/groups/plggeurvalve/slurm_outputs/slurm-%j.err
      EXECSETTINGS
    end
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
