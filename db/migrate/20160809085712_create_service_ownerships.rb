class CreateServiceOwnerships < ActiveRecord::Migration[5.0]
  def change
    create_table :service_ownerships do |t|
      t.belongs_to :service, index: true
      t.belongs_to :user, index: true
      t.timestamps
    end

    add_index :service_ownerships, [:user_id, :service_id], unique: true
  end
end
