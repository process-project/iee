# frozen_string_literal: true

class GroupRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'Group', foreign_key: 'parent_id'
  belongs_to :child, class_name: 'Group', foreign_key: 'child_id'

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
