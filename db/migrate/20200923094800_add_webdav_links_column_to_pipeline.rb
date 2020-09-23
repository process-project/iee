class AddWebdavLinksColumnToPipeline < ActiveRecord::Migration[5.1]
  def change
    add_column :pipelines, :webdav_links, :json
  end
end
