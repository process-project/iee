# frozen_string_literal: true
class ServicesController < ApplicationController
  before_action :find_and_authorize,
                only: [:update, :destroy]

  def index
    @services = policy_scope(Service).order(:name)
  end

  def new
    @service = Service.new
  end

  def show
    @service = Service.includes(:access_methods).find(params[:id])
    authorize(@service)
  end

  def create
    @service = Service.new(permitted_attributes(Service).merge(access_method_params))
    @service.users << current_user

    if @service.save
      redirect_to(services_path)
    else
      render(:new)
    end
  end

  def edit
    @service = Service.includes(:access_methods, :users).find(params[:id])
    authorize(@service)
  end

  def update
    if @service.update_attributes(permitted_attributes(@service).merge(access_method_params))
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

  def access_method_params
    { access_methods: present_access_methods + new_access_methods }
  end

  def present_access_methods
    @service ? @service.access_methods.where(id: params[:service][:access_method_ids]) : []
  end

  def new_access_methods
    new_access_method_names =
      (params[:service][:access_method_ids] || []).
      uniq.
      select do |value|
        value.present? &&
          AccessMethod.where(id: value).
            or(AccessMethod.where(name: value, service: [nil, @service&.id])).
            empty?
      end
    new_access_method_names.map { |name| AccessMethod.new(name: name) }
  end

  def find_and_authorize
    @service = Service.find(params[:id])
    authorize(@service)
  end
end
