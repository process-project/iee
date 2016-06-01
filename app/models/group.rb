class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :permissions, dependent: :destroy
  has_many :subgroups, class_name: 'Group', foreign_key: 'parent_group'
  belongs_to :parent_group, class_name: 'Group'

  validates :name, presence: true

  def all_parents
    if parent_group
      [parent_group] + parent_group.all_parents
    else
      []
    end
  end

  def all_parents_comp
    ([parent_group] + [parent_group.try(:parent_group)]).flatten.compact!
  end
end
