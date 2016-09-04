# frozen_string_literal: true
class ServicesController < ApplicationController
  def index
    @services = policy_scope(Service).order(:name)
  end

  def new
    @service = Service.new
    # @service.uri_aliases << 'http://abc.pl'
    # @service.uri_aliases << 'http://def.pl'
  end

  def create
    @service = Service.new(service_params)
    @service.users << current_user

    if @service.save
      redirect_to(services_path)
    else
      render(:new)
    end
  end

  def destroy
    service = Service.find(params[:id])

    if service
      authorize(service)
      service.destroy
    end

    redirect_to services_path
  end

  private

  def service_params
    params.require(:service).permit([:name, :uri, uri_aliases: []])
  end
end
