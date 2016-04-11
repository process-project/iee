class AddProxyToUser < ActiveRecord::Migration
  def change
    add_column :users, :proxy, :text
  end
end
