class AddTypeToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :resource_type, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        resources = execute("SELECT * FROM resources")
        resources.each do |resource|
          if resource['path'].start_with?('webdav')
            execute("UPDATE resources SET resource_type = 0 WHERE id = #{resource['id']}")
          else
            execute("UPDATE resources SET resource_type = 1 WHERE id = #{resource['id']}")
          end
        end
      end
    end
  end
end
