# frozen_string_literal: true

module CheckExistenceConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def exists_for_attribute?(attribute_name, values, additional_where = {})
      clause = "#{connection.quote_column_name(attribute_name)} IN (?)"
      select(attribute_name).where(clause, values).
        where(additional_where).
        distinct.count == values.uniq.length
    end
  end
end
