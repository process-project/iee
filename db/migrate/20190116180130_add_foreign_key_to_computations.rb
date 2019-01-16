class AddForeignKeyToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :container_registry_id, :integer, null: true
    add_foreign_key :computations, :container_registries
  end
end
