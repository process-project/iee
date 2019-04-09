class ActivityLogWriter
  def self.write_message(user, pipeline, computation, message)
    record = ActivityLog.new
    if user.present?
      record.user_id = user.id
      record.user_email = user.email
    end
    if pipeline.present?
      record.project_name = pipeline.project.project_name
      record.pipeline_id = pipeline.id
      record.pipeline_name = pipeline.name
    end
    if computation.present?
      record.computation_id = computation.id
      record.pipeline_step_name = computation.pipeline_step
    end
    record.message = message
    record.save
  end
end
