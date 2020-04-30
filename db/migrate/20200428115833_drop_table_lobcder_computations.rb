class DropTableLobcderComputations < ActiveRecord::Migration[5.1]
  def change
    drop_table :lobcder_computations
  end
end
