# frozen_string_literal: true
module CheckExistenceConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def exists_for_attribute?(attribute_name, values, additional_where = {})
      select(attribute_name).where(attribute_name + ' IN (?)', values).
        where(additional_where).
        distinct.count == values.uniq.length
    end
  end
end
