# frozen_string_literal: true

class GroupRelationship < ApplicationRecord
  belongs_to :parent,
             class_name: 'Group',
             foreign_key: 'parent_id',
             inverse_of: 'child_group_relationship'

  belongs_to :child,
             class_name: 'Group',
             foreign_key: 'child_id',
             inverse_of: 'parent_group_relationship'

  validate :no_cycles

  private

  def no_cycles
    errors.add(:base, 'Cycles are not allowed') if cycle?
  end

  def cycle?
    parent == child ||
      parent.ancestors.include?(child) ||
      child.offspring.include?(parent)
  end
end
