class AddContainerNameToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :container_name, :string
  end
end
