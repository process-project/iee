class AddParentGroupToGroup < ActiveRecord::Migration
  def change
    add_reference :groups, :parent_group, index: true
  end
end
