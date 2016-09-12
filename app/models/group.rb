# frozen_string_literal: true
class Group < ApplicationRecord
  include CheckExistenceConcern

  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :access_policies, dependent: :destroy
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

  after_save :owner_ids_into_user_groups
  after_save :member_ids_into_user_groups

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

  attr_writer :member_ids
  def member_ids
    members.pluck(:id)
  end

  attr_writer :owner_ids
  def owner_ids
    owners.pluck(:id)
  end

  def members
    users.joins(:user_groups).where(user_groups: { owner: false }).distinct
  end

  def owners
    users.joins(:user_groups).where(user_groups: { owner: true }).distinct
  end

  private

  def owner_ids_into_user_groups
    return unless @owner_ids

    owners = User.where(id: @owner_ids)
    create_user_groups(owners, owner: true)
    destroy_non_existing(owners, owner: true)
  end

  def member_ids_into_user_groups
    return unless @member_ids

    @member_ids -= @owner_ids if @owner_ids
    members = User.where(id: @member_ids)
    create_user_groups(members, owner: false)
    destroy_non_existing(members, owner: false)
  end

  def create_user_groups(members, owner:)
    members.each do |member|
      user_group = user_groups.find_or_initialize_by(user: member)
      user_group.update(owner: owner)
    end
  end

  def destroy_non_existing(members, owner:)
    user_groups.where(owner: owner).where.not(user: members).destroy_all
  end
end
