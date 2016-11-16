# frozen_string_literal: true
class MigrateResourceManagers < ActiveRecord::Migration[5.0]
  def up
    manage_response = execute('SELECT id from access_methods WHERE name = \'manage\'')
    return unless manage_response.first

    manage_id = manage_response.first['id']
    manage_aps = execute(<<~SQL
      SELECT * FROM access_policies
      WHERE access_method_id = '#{manage_id}'
    SQL
                        )

    manage_aps.each do |ap|
      execute(<<~SQL
        INSERT INTO resource_managers(
          resource_id, user_id, group_id, created_at, updated_at
        )
        VALUES(
          '#{ap['resource_id']}', #{v(ap['user_id'])}, #{v(ap['group_id'])},
          '#{ap['created_at']}', '#{ap['updated_at']}'
        )
      SQL
            )
    end

    execute("DELETE FROM access_policies WHERE access_method_id = '#{manage_id}'")
    execute('DELETE FROM access_methods WHERE name = \'manage\'')
  end

  def down
    manage_id = execute(<<~SQL
      INSERT INTO access_methods(name, created_at, updated_at)
      VALUES('manage', '#{Time.zone.now.to_s}', '#{Time.zone.now.to_s}')
      RETURNING id
    SQL
                       ).first['id']

    execute('SELECT * FROM resource_managers').each do |m|
      execute(<<~SQL
        INSERT INTO access_policies(
          resource_id, user_id, group_id, access_method_id, created_at, updated_at
        )
        VALUES(
          '#{m['resource_id']}', #{v(m['user_id'])}, #{v(m['group_id'])},
          '#{manage_id}', '#{m['created_at']}', '#{m['updated_at']}'
        )
      SQL
             )
    end

    execute('DELETE FROM resource_managers')
  end

  def v(v)
    v.blank? ? 'NULL' : "'#{v}'"
  end
end
