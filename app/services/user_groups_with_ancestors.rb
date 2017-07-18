# frozen_string_literal: true

class UserGroupsWithAncestors
  def initialize(user)
    @user = user
  end

  def get
    groups = @user.groups.to_a
    @user.groups.each do |g|
      groups += g.ancestors
    end
    groups.uniq
  end
end
