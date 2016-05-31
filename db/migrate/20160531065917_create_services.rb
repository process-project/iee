class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :uri, unique: true, null: false, index: true
      t.string :token, null: false, unique: true
      t.string :name
      t.boolean :editable_by_user, null: false, default: false

      t.timestamps null: false
    end

    change_table :resources do |t|
      t.belongs_to :service, index: true
      t.rename :uri, :path
    end

    change_column_null :resources, :name, true

    reversible do |dir|
      dir.up do
        Resource.find_each do |resource|
          uri = URI.parse(resource.path)
          service = Service.find_or_create_by(
            uri: "#{uri.scheme || 'https'}://#{uri.host}")

          resource.update_columns(service_id: service.id, path: uri.path)
        end
      end

      dir.down do
        Resource.joins(:service).find_each do |resource|
          uri = URI.parse(resource.service.uri)
          uri.path = if resource.path.start_with?('/')
                       resource.path
                     else
                       "/#{resource.path}"
                     end
          resource.update_column(:path, uri.to_s)
        end
      end
    end

    change_column_null :resources, :service_id, false
  end
end
