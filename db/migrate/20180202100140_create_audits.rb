class CreateAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :audits do |t|
      t.string :ip
      t.string :user_agent
      t.string :accept_language

      t.belongs_to :user

      t.timestamps
    end
  end
end
