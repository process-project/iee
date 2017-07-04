# frozen_string_literal: true

class CreateServiceOwnerships < ActiveRecord::Migration[5.0]
  def change
    create_table :service_ownerships do |t|
      t.belongs_to :service, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.timestamps
    end

    add_index :service_ownerships, [:user_id, :service_id], unique: true
  end
end
