class AddTypeToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :resource_type, :integer, default: 0, null: false
  end
end
