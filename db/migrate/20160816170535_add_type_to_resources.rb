class AddTypeToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :resource_type, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Resource.all.each do |resource|
          resource.path.start_with?('webdav') ? resource.global! : resource.local!
        end
      end
    end
  end
end
