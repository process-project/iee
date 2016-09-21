# frozen_string_literal: true
class ServicesController < ApplicationController
  before_action :find_and_authorize,
                only: [:show, :edit, :update, :destroy]

  def index
    @services = policy_scope(Service).includes(:users).order(:name)
  end

  def new
    @service = Service.new
  end

  def show
  end

  def create
    @service = Service.new(permitted_attributes(Service))
    @service.users << current_user

    if @service.save
      redirect_to(services_path)
    else
      render(:new)
    end
  end

  def edit
  end

  def update
    if @service.update_attributes(permitted_attributes(@service))
      redirect_to(service_path(@service))
    else
      render(:edit)
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path
  end

  private

  def find_and_authorize
    @service = Service.find(params[:id])
    authorize(@service)
  end
end
