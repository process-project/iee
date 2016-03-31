class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :action
  belongs_to :resource

  validates :user, presence: true, if: 'group == nil'
  validates :user, absence: true, if: 'group != nil'

  validates :group, presence: true, if: 'user == nil'
  validates :group, absence: true, if: 'user != nil'
end
