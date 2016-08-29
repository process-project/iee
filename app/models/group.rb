# frozen_string_literal: true
class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :access_policies, dependent: :destroy
  has_many :subgroups, class_name: 'Group', foreign_key: 'parent_group_id'
  belongs_to :parent_group, class_name: 'Group'

  validates :name, presence: true
  validates :name, uniqueness: true
  validate :no_cycles_in_ancestors

  before_save :owner_ids_into_user_groups
  before_save :member_ids_into_user_groups

  def self.names_exist?(names)
    Group.where(name: names).count == names.length
  end

  def ancestors
    if parent_group
      [parent_group] + parent_group.ancestors
    else
      []
    end
  end

  def offspring
    if subgroups
      subgroups.collect { |subgroup| [subgroup] + subgroup.offspring }.flatten
    else
      []
    end
  end

  attr_writer :member_ids
  def member_ids
    members.pluck(:id)
  end

  attr_writer :owner_ids
  def owner_ids
    owners.pluck(:id)
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

  def no_cycles_in_ancestors
    errors.add(:parent_group, 'Cannot be one of ancestors') if offspring.include? parent_group
  end

  def members
    users.joins(:user_groups).where(user_groups: { owner: false })
  end

  def owners
    users.joins(:user_groups).where(user_groups: { owner: true })
  end
end
