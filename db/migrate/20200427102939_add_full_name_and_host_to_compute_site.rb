class AddFullNameAndHostToComputeSite < ActiveRecord::Migration[5.1]
  def change
    add_column :compute_sites, :full_name, :string
    add_column :compute_sites, :host, :string
  end
end
