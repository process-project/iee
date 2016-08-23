# frozen_string_literal: true
module GroupsHelper
  def name_list(collection)
    collection.map(&:name).join(', ')
  end
end
