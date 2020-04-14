class CreateActivityLog < ActiveRecord::Migration[5.1]
  def change
    create_table :activity_logs do |t|
      t.string :user_id
      t.string :user_email
      t.string :project_name
      t.string :pipeline_id
      t.string :pipeline_name
      t.string :computation_id
      t.string :pipeline_step_name

      t.string :message, default: ''

      t.timestamps
    end
  end
end
