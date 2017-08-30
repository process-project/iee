class AddFlowToPipeline < ActiveRecord::Migration[5.1]
  def change
    add_column :pipelines, :flow, :string, default: Pipeline::FLOWS.first, null: false
  end
end
