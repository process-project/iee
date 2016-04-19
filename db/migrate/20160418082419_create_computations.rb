class CreateComputations < ActiveRecord::Migration
  def change
    create_table :computations do |t|
      t.string :job_id
      t.text :script, nil: false
      t.string :working_directory, unique: true
      t.string :status, nil: false, default: 'new'

      t.string :stdout_path
      t.string :stderr_path
      t.text :standard_output
      t.text :error_output
      t.string :error_message

      t.integer :exit_code

      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
