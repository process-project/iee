class AddPipelineInputs < ActiveRecord::Migration[5.1]
  def change
    add_reference :data_files, :input_of,
                  index: true, foreign_key: { to_table: :pipelines }
    rename_column :data_files, :pipeline_id, :output_of_id
  end
end
