class CreateComputeSites < ActiveRecord::Migration[5.1]
  def change
    create_table :compute_sites do |t|
      t.string :name

      t.timestamps
    end
  end
end
