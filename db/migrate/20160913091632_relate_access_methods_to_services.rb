class RelateAccessMethodsToServices < ActiveRecord::Migration[5.0]
  def change
    add_reference :access_methods, :service, index: true, foreign_key: true
  end
end
