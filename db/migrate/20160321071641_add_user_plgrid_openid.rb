# frozen_string_literal: true
class AddUserPlgridOpenid < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :plgrid_login, :string
    add_index :users, :plgrid_login, unique: true
  end
end
