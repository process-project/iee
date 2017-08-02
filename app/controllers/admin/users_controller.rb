# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :find_and_authorize_user, except: :index

    def index
      authorize(User)

      @users = policy_scope(User)
      @users = case state
               when 'active' then @users.approved
               when 'new' then @users.new_accounts
               when 'blocked' then @users.blocked
               else @users
               end.order(:last_name, :first_name)
    end

    def destroy
      if me?
        redirect_to(admin_users_path, alert: t('me'))
      elsif @user.destroy
        redirect_to(admin_users_path, notice: t('success', user: @user.name))
      else
        redirect_to(admin_users_path, alert: t('error'))
      end
    end

    def update
      if block_yourself?
        redirect_to(admin_users_path, alert: t('me'))
      elsif @user.update_attributes(state: state)
        redirect_to(admin_users_path, notice: state_changed_msg)
      else
        redirect_to(admin_users_path, alert: t('error'))
      end
    end

    private

    def state
      params[:state]
    end

    def state_changed_msg
      t('success', user: @user.name, state: state)
    end

    def t(key, hsh = {})
      I18n.t("admin.users.#{action_name}.#{key}", hsh)
    end

    def block_yourself?
      me? && params[:state] == 'blocked'
    end

    def me?
      @user == current_user
    end

    def find_and_authorize_user
      @user = User.find(params[:id])
      authorize(@user)
    end
  end
end
