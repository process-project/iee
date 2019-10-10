class CreateComputeSiteProxies < ActiveRecord::Migration[5.1]
  def change
    create_table :compute_site_proxies do |t|
      t.string :value

      t.timestamps
    end
  end
end
