class AddPipelineTypeToPipeline < ActiveRecord::Migration[5.1]
  def change
    add_column :pipelines, :pipeline_type, :string, default: 'full_body_scan', null: false
  end
end
