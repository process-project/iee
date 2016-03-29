class AccountConfirmationController < ApplicationController
  before_filter :user_is_supervisor
  
  def index
  end
  
  def approve
    user = User.find(params[:id])
    
    if user
      logger.info "Approving #{user.email} by #{current_user.email}"
      user.approved = true
      user.save
      flash[:notice] = t("user_approved", email: user.email)
    end
    
    redirect_to(action: "index")
  end
  
  def approve_all
    logger.info "Approving all pending users by #{current_user.email}"
    
    User.where(approved: false).update_all(approved: true)
    
    flash[:notice] = t("all_approved")
    
    redirect_to(action: "index")
  end
  
  def block
    user = User.find(params[:id])
    
    if user
      if user == current_user
        flash[:alert] = t("cannot_block_itself")
      else
        logger.info "Blocking #{user.email} by #{current_user.email}"
        user.approved = false
        user.save
        flash[:notice] = t("user_blocked", email: user.email)
      end
    end
    
    redirect_to(action: "index")
  end
  
  def block_all
    logger.info "Blocking all non-supervisor and non-admin accounts by #{current_user.email}"
    
    user_ids = User.eager_load(:groups).where("groups.name NOT IN (?) OR groups.id IS NULL",
        ["admin", "supervisor"]).map do |user|
      user.id
    end
    User.where(id: user_ids).update_all(approved: false)
    
    flash[:notice] = t("all_blocked")
    
    redirect_to(action: "index")
  end
  
  private
  
  def user_is_supervisor
    if !view_context.supervisor?
      flash[:alert] = t("restricted_to_supervisors")
      redirect_to root_path
    end
  end
end
