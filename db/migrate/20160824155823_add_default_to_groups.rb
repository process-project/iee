class AddDefaultToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :default, :boolean, default: false, null: false
  end
end
