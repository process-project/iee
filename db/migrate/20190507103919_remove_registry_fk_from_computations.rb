class RemoveRegistryFkFromComputations < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :computations, :container_registries
    remove_column :computations, :container_registry_id
  end
end
