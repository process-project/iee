class AddUriAliasesToService < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :uri_aliases, :string, array: true, default: []
    # GIN vs. GiST indexes: https://www.postgresql.org/docs/current/static/textsearch-indexes.html
    add_index :services, :uri_aliases, using: 'gin'
  end
end
