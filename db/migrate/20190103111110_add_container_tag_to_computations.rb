class AddContainerTagToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :container_tag, :string
  end
end
