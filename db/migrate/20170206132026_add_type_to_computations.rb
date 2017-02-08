class AddTypeToComputations < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :computation_type, :integer, index: true, default: 0, null: false
  end
end
