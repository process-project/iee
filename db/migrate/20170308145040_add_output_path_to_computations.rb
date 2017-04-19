class AddOutputPathToComputations < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :output_path, :string
  end
end
