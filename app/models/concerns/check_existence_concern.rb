# frozen_string_literal: true
module CheckExistenceConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def exists_for_attribute?(attribute_name, values)
      where(attribute_name + ' IN (?)', values).count == values.length
    end
  end
end
