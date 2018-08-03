class CreateIps < ActiveRecord::Migration[5.1]
  def change
    create_table :ips do |t|
      t.string :address

      t.belongs_to :user_agent

      t.timestamps
    end
  end
end
