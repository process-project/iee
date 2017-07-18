# frozen_string_literal: true

class RefactorGroupRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :group_relationships do |t|
      t.belongs_to :parent, foreign_key: { to_table: :groups }, null: false
      t.belongs_to :child, foreign_key: { to_table: :groups }, null: false

      t.timestamps
    end
    add_index :group_relationships, [:parent_id, :child_id], unique: true
    remove_reference :groups, :parent_group, index: true
  end
end
