class CreateUserComputeSiteProxyRelation < ActiveRecord::Migration[5.1]
  def change
    change_table :compute_site_proxies do |t|
    	t.belongs_to :compute_sites
      t.belongs_to :users
    end
  end
end
