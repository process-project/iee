# frozen_string_literal: true

class ExclusivelyOwnedGroups
  def initialize(user)
    @user = user
  end

  def call
    Group.joins(:user_groups).
      where(user_groups: { user: @user },
            id: group_with_only_one_owner)
  end

  private

  def group_with_only_one_owner
    Group.joins(:user_groups).
      where(user_groups: { owner: true }).
      group(:id).
      having('count(user_groups.id) = 1')
  end
end
