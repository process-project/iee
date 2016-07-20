class CreateComputations < ActiveRecord::Migration[4.2]
  def change
    create_table :computations do |t|
      t.string :job_id
      t.text :script, null: false
      t.string :working_directory
      t.string :status, null: false, default: 'new'

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
