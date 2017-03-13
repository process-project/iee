# frozen_string_literal: true
class ComputationScriptGenerator
  def initialize(patient, user)
    @patient = patient
    @user = user
  end

  def script
    header + stage_in + job_script + stage_out
  end

  private

  def grant_id
    Rails.application.config_for('eurvalve')['grant_id']
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

  def synchronizer
    @synchronizer ||= DataFile.synchronizer_class.new(@patient, @user)
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
end
