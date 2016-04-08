class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :case_number, null: false, index: true
      t.integer :procedure_status, null: false, index: true, default: 0

      t.timestamps null: false
    end
  end
end
