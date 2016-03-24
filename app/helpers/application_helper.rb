module ApplicationHelper
  def supervisor?
    if current_user
      @is_supervisor = current_user.groups.where(name: "supervisor")
    else
      @is_supervisor = false
    end
  end
end