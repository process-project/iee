class DeleteUnsupportedPipelinesFromDb < ActiveRecord::Migration[5.1]
  def change
    # Delete all pipelines and related records in other relations
    # (deleting all pipelines => deleting all computations)
    ActiveRecord::Base.connection.execute("TRUNCATE computations")
    ActiveRecord::Base.connection.execute("DELETE FROM data_files WHERE input_of_id IS NOT NULL OR output_of_id IS NOT NULL")
    ActiveRecord::Base.connection.execute("TRUNCATE pipelines")
  end
end
