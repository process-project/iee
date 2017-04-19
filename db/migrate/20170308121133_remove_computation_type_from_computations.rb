class RemoveComputationTypeFromComputations < ActiveRecord::Migration[5.0]
  def change
    remove_column :computations, :computation_type, :string
  end
end
