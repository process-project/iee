class AccountConfirmationController < ApplicationController
  def index
    @users = {}
    @users[:confirmed] = User.where(approved: true)
    @users[:not_confirmed] = User.where(approved: false)
    @user_confirmations = @users[:not_confirmed].exists?
  end
  
  def approve
    user = User.find(params[:id])
    
    if user and view_context.supervisor?
      logger.info "Approving #{user.email} by #{current_user.email}"
      user.approved = true
      user.save
      flash[:notice] = t("user_approved", email: user.email)
    end
    
    redirect_to(action: "index")
  end
  
  def approve_all
    if view_context.supervisor?
      logger.info "Approving all pending users by #{current_user.email}"
      
      User.where(approved: false).each do |user|
        user.approved = true
        user.save
      end
      
      flash[:notice] = t("all_approved")
    end
    
    redirect_to(action: "index")
  end
  
  def block
    user = User.find(params[:id])
    
    if user and view_context.supervisor?
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
    if view_context.supervisor?
      logger.info "Blocking all non-supervisor and non-admin accounts by #{current_user.email}"
      
      User.eager_load(:groups).where("groups.name NOT IN (?) OR groups.id IS NULL",
          ["admin", "supervisor"]).each do |user|
        user.approved = false
        user.save
      end
      
      flash[:notice] = t("all_blocked")
    end
    
    redirect_to(action: "index")
  end
end
