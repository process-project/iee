class AddHpcToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :hpc, :string
  end
end
