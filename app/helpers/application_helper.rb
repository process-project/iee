module ApplicationHelper
  include HamlHelper
  
  def supervisor?
    if current_user
      current_user.groups.where(name: "supervisor").exists?
    else
      false
    end
  end
end