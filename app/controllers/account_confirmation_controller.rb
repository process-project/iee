# frozen_string_literal: true
class AccountConfirmationController < ApplicationController
  before_action :user_is_supervisor

  def index
  end

  def approve
    user = User.find(params[:id])

    if user
      approve_user(user)
      flash[:notice] = t('user_approved', email: user.email)
      Notifier.account_approved(user).deliver_later
    end

    redirect_to(action: 'index')
  end

  def approve_all
    logger.info "Approving all pending users by #{current_user.email}"
    not_approved = User.where(approved: false)

    not_approved.each { |u| Notifier.account_approved(u).deliver_later }
    not_approved.update_all(approved: true)

    flash[:notice] = t('all_approved')
    redirect_to(action: 'index')
  end

  def block
    @user = User.find(params[:id])

    if @user
      if @user == current_user
        flash[:alert] = t('cannot_block_itself')
      else
        perform_blocking
        flash[:notice] = t('user_blocked', email: @user.email)
      end
    end

    redirect_to(action: 'index')
  end

  def block_all
    logger.info "Blocking all non-supervisor and non-admin accounts by #{current_user.email}"

    user_ids = User.eager_load(:groups).where('groups.name NOT IN (?) OR groups.id IS NULL',
                                              %w(admin supervisor)).map(&:id)
    User.where(id: user_ids).update_all(approved: false)

    flash[:notice] = t('all_blocked')

    redirect_to(action: 'index')
  end

  private

  def approve_user(user)
    logger.info "Approving #{user.email} by #{current_user.email}"
    user.update_attribute(:approved, true)
  end

  def user_is_supervisor
    unless view_context.supervisor?
      flash[:alert] = t('restricted_to_supervisors')
      redirect_to root_path
    end
  end

  def perform_blocking
    logger.info "Blocking #{@user.email} by #{current_user.email}"
    @user.approved = false
    @user.save
  end
end
