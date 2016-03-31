class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :group, index: true
      t.belongs_to :user, index: true
      t.belongs_to :action, null: false, index: true
      t.belongs_to :resource, null: false, index: true

      t.timestamps null: false
    end
  end
end
