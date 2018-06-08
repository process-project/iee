class CreateUserAgents < ActiveRecord::Migration[5.1]
  def change
    create_table :user_agents do |t|
      t.string :name
      t.string :accept_language

      t.belongs_to :user

      t.timestamps
    end
  end
end
