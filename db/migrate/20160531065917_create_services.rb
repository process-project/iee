# frozen_string_literal: true

class CreateServices < ActiveRecord::Migration[4.2]
  def change
    create_table :services do |t|
      t.string :uri, unique: true, null: false, index: true
      t.string :token, null: false, unique: true
      t.string :name

      t.timestamps null: false
    end

    change_table :resources do |t|
      t.belongs_to :service, index: true
      t.rename :uri, :path
    end

    change_column_null :resources, :name, true

    reversible do |dir|
      dir.up do
        resources = execute("SELECT * FROM resources")
        resources.each do |resource|
          uri = URI.parse(resource['path'])
          uri_path = "#{uri.scheme || 'https'}://#{uri.host}"
          services = execute("SELECT id FROM services WHERE uri = '#{uri_path}'")
          if services.count == 0
            token ||= loop do
              random_token = SecureRandom.hex
              token_clash = execute("SELECT id FROM services WHERE token = '#{random_token}'")
              break random_token unless token_clash.count > 0
            end
            sql = <<-SQL
              INSERT INTO services(uri, token, created_at, updated_at)
              VALUES ('#{uri_path}', '#{token}', '#{Time.now.to_s}', '#{Time.now.to_s}')
              RETURNING id
            SQL
            service_id = execute(sql).first['id']
          else
            service_id = services.first['id']
          end
          execute ("UPDATE resources SET service_id = #{service_id}, path = '#{uri.path}' WHERE id = #{resource['id']}")
        end
      end

      dir.down do
        resources = execute("SELECT * FROM resources JOIN services ON resources.service_id = services.id")
        resources.each do |resource|
          uri = URI.parse(resource['uri'])
          uri.path = if resource['path'].start_with?('/')
                       resource['path']
                     else
                       "/#{resource['path']}"
                     end
          execute "UPDATE resources SET path = '#{uri.to_s}' WHERE id = #{resource['id']}"
        end
      end
    end

    change_column_null :resources, :service_id, false
  end
end
