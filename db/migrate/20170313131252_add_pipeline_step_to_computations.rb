class AddPipelineStepToComputations < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :pipeline_step, :string
  end
end
