# frozen_string_literal: true
class CreateDataFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :data_files do |t|
      t.string :name, null: false
      t.string :handle
      t.integer :data_type, null: false, index: true
      t.belongs_to :patient, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
