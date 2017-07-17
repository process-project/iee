# frozen_string_literal: true

class CreateUserGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :user_groups do |t|
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true
      t.boolean :owner, null: false, default: false
      t.timestamps null: false
    end
  end
end
