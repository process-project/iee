class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :permissions, dependent: :destroy
  has_many :subgroups, class_name: 'Group', foreign_key: 'parent_group_id'
  belongs_to :parent_group, class_name: 'Group'

  validates :name, presence: true
  validate :no_cycles_in_ancestors

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

  private
  def no_cycles_in_ancestors
    if offspring.include? parent_group
      errors.add(:parent_group, 'Cannot be one of ancestors')
    end
  end
end
