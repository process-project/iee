class AddPipelineInputs < ActiveRecord::Migration[5.1]
  def change
    add_reference :data_files, :input_pipeline,
                  index: true, foreign_key: { to_table: :pipelines }
    rename_column :data_files, :pipeline_id, :output_pipeline_id
  end
end
