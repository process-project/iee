class AddComputeSiteRelatedColumnsToComputations < ActiveRecord::Migration[5.1]
  def change
    add_reference :computations, :compute_site,
                  foreign_key: {to_table: :compute_sites}, null: true
    add_reference :computations, :src_compute_site,
                  foreign_key: {to_table: :compute_sites}, null: true
    add_reference :computations, :dest_compute_site,
                  foreign_key: {to_table: :compute_sites}, null: true
  end
end
