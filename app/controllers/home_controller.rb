class HomeController < ApplicationController
  def index
    redirect_to edit_user_registration_path
  end
end
