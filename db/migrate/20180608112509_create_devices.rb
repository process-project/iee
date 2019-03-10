# frozen_string_literal: true

class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :accept_language

      t.belongs_to :user

      t.timestamps
    end
  end
end
