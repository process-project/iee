# frozen_string_literal: true
class ComputationScriptGenerator
  def script
    header + stage_in + job_script + stage_out
  end

  def initialize(patient, user)
    @patient = patient
    @user = user
  end

  private

  def header
    invalid_usage
  end

  def invalid_usage
    raise 'Method called on abstract base class. Use specializations of this class instead.'
  end

  def stage_in
    invalid_usage
  end

  def job_script
    invalid_usage
  end

  def stage_out
    invalid_usage
  end

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
