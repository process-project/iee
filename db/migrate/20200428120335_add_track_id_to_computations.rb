class AddTrackIdToComputations < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :track_id, :string
  end
end
