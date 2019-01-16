class CreateContainerRegistries < ActiveRecord::Migration[5.1]
  def change
    create_table :container_registries do |t|
      t.string :registry_url

      t.timestamps
    end
  end
end
