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
      perform(t('success', user: @user.name)) do
        ::Users::Destroy.new(current_user, @user).call
      end
    end

    def update
      perform(t('success', user: @user.name, state: state)) do
        ::Users::ChangeState.new(current_user, @user, state).call
      end
    end

    private

    def state
      params[:state]
    end

    def perform(ok_msg)
      case result = yield
      when :ok then redirect_to(admin_users_path, notice: ok_msg)
      else redirect_to(admin_users_path, alert: t(result))
      end
    end

    def t(key, hsh = {})
      I18n.t("admin.users.#{action_name}.#{key}", hsh)
    end

    def find_and_authorize_user
      @user = User.find(params[:id])
      authorize(@user)
    end
  end
end
