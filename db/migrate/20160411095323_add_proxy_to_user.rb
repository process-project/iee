# frozen_string_literal: true

class AddProxyToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :proxy, :text
  end
end
