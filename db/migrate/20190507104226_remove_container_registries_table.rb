class RemoveContainerRegistriesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :container_registries
  end
end
