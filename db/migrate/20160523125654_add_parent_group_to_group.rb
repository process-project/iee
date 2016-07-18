class AddParentGroupToGroup < ActiveRecord::Migration[4.2]
  def change
    add_reference :groups, :parent_group, index: true
  end
end
