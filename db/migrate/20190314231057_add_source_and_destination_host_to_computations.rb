class AddSourceAndDestinationHostToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :src_host, :string
    add_column :computations, :dest_host, :string
  end
end
