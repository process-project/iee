# frozen_string_literal: true
class CreateActions < ActiveRecord::Migration[4.2]
  def change
    create_table :actions do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end
  end
end
