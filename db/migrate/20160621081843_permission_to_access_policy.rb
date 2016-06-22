class PermissionToAccessPolicy < ActiveRecord::Migration
  def change
    rename_table :permissions, :access_policies
  end
end
