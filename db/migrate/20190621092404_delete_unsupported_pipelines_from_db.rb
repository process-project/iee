class DeleteUnsupportedPipelinesFromDb < ActiveRecord::Migration[5.1]
  def change
    # Delete all pipelines and related records in other relations
    # (deleting all pipelines => deleting all computations)
    ActiveRecord::Base.connection.execute("TRUNCATE pipelines CASCADE")
  end
end
