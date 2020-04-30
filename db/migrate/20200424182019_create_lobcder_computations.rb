class CreateLobcderComputations < ActiveRecord::Migration[5.1]
  def change
    create_table :lobcder_computations do |t|
      t.string :src_path
      t.string :dest_path
      t.string :src_host
      t.string :dest_host
      t.string :track_id

      t.timestamps
    end
  end
end
