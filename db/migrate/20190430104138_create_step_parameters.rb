class CreateStepParameters < ActiveRecord::Migration[5.1]
  def change
    create_table :step_parameters do |t|
      t.string :label
      t.string :name
      t.string :description
      t.integer :rank
      t.string :datatype
      t.string :default
      t.string :values

      t.timestamps
    end
  end
end
