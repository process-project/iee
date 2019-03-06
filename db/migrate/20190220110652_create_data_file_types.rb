# frozen_string_literal: true

class CreateDataFileTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :data_file_types do |t|
      t.string :data_type, null: false, unique: true
      t.text :pattern, null: false

      t.timestamps
    end
  end
end
