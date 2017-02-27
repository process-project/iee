# frozen_string_literal: true
class ChangePdpIntoInsensitive < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'citext'

    change_column :access_methods, :name, :citext, unique: true, index: true
    change_column :resources, :path, :citext, index: true
  end
end
