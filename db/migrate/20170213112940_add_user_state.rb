# frozen_string_literal: true

class AddUserState < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :state, :integer, default: 0, null: false, index: true

    execute('SELECT id FROM users where approved = true').each do |r|
      execute("UPDATE users set state = 1 WHERE id = #{r['id']}")
    end

    remove_column :users, :approved
  end

  def down
    add_column :users, :approved, :boolean, default: false, null: false

    execute('SELECT id FROM users where state = 1').each do |r|
      execute("UPDATE users set approved = true WHERE id = #{r['id']}")
    end

    remove_column :users, :state
  end
end
