class AddRegistryUrlToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :registry_url, :string
  end
end
