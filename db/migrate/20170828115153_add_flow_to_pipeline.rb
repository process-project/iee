class AddFlowToPipeline < ActiveRecord::Migration[5.1]
  def change
    add_column :pipelines, :flow, :string, default: 'full_body_scan', null: false
  end
end
