class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name, null: false
      t.string :uri, null: false, index: true

      t.timestamps null: false
    end
  end
end
