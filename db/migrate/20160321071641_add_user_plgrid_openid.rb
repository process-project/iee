class AddUserPlgridOpenid < ActiveRecord::Migration
  def change
    add_column :users, :plgrid_login, :string
    add_index :users, :plgrid_login, unique: true
  end
end
