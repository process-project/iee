# frozen_string_literal: true
class GroupRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'Group', foreign_key: 'parent_id'
  belongs_to :child, class_name: 'Group', foreign_key: 'child_id'
end
