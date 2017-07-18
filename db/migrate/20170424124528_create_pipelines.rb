# frozen_string_literal: true

class CreatePipelines < ActiveRecord::Migration[5.0]
  def change
    create_table :pipelines do |t|
      t.string :name, null: false
      t.integer :iid, null: false, index: true

      t.belongs_to :patient, null: false, index: true
      t.belongs_to :user, null: false

      t.timestamps
    end

    add_index :pipelines, [:patient_id, :iid], unique: true
  end
end
