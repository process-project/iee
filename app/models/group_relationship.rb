# frozen_string_literal: true
class GroupRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'Group', foreign_key: 'parent_id'
  belongs_to :child, class_name: 'Group', foreign_key: 'child_id'

  validate :no_cycles_in_ancestors

  private

  def no_cycles_in_ancestors
    errors.add(:child_id, 'Cannot be one of ancestors') if cycle?
  end

  def cycle?
    parent == child || child.offspring.include?(parent)
  end
end
