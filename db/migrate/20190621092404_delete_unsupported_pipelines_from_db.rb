class DeleteUnsupportedPipelinesFromDb < ActiveRecord::Migration[5.1]
  def change
    Pipeline.where.not(flow: Flow.types).destroy_all
  end
end
