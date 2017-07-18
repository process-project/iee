# frozen_string_literal: true

class Group < ApplicationRecord
  include CheckExistenceConcern

  has_many :user_groups, autosave: true
  has_many :users, through: :user_groups
  has_many :access_policies, dependent: :destroy
  has_many :resource_managers, dependent: :destroy
  has_many :parent_group_relationship,
           class_name: 'GroupRelationship',
           foreign_key: 'child_id',
           dependent: :destroy,
           inverse_of: :child
  has_many :child_group_relationship,
           class_name: 'GroupRelationship',
           foreign_key: 'parent_id',
           dependent: :destroy,
           inverse_of: :parent
  has_many :parents,
           through: :parent_group_relationship,
           source: :parent
  has_many :children,
           through: :child_group_relationship,
           source: :child

  validates :name, presence: true
  validates :name, uniqueness: true
  validate :at_least_one_owner

  def ancestors
    parents + parents.map(&:ancestors).flatten
  end

  def offspring
    children + children.map(&:offspring).flatten
  end

  def offspring_candidates
    Group.all - ancestors - [self]
  end

  def all_users
    (users + offspring.map(&:users).flatten).uniq
  end

  def members
    users.joins(:user_groups).where(user_groups: { owner: false }).distinct
  end

  def owners
    users.joins(:user_groups).where(user_groups: { owner: true }).distinct
  end

  private

  def at_least_one_owner
    errors.add(:owner_ids, 'At least one group owner is required') unless user_groups.any?(&:owner)
  end
end
