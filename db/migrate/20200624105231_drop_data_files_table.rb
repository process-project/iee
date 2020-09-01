class DropDataFilesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :data_files
  end
end
