# frozen_string_literal: true

class CreateResourceManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_managers do |t|
      t.belongs_to :resource
      t.belongs_to :user
      t.belongs_to :group

      t.timestamps
    end
  end
end
