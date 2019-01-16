class RemoveRegistryUrlFromComputations < ActiveRecord::Migration[5.1]
  def change
    remove_column :computations, :registry_url, :string
  end
end
