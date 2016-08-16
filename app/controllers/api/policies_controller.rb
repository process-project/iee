# frozen_string_literal: true
module Api
  class PoliciesController < Api::ServiceController
    before_action :parse_request, only: :create

    before_action only: :create do
      render_bad_request unless json_params_valid?
    end

    def index
    end

    def create
      Resource.transaction do
        resource = Resource.create(service: service, path: @json['resource_path'])
        user = User.find_by(email: @json['user'])
        @json['access_methods'].each do |access_method|
          create_access_policy(user, access_method, resource)
        end
      end

      head :created
    end

    def destroy
      resource = Resource.find_by(path: resource_path_param, service: service)

      if resource
        resource.destroy
        head :no_content
      else
        head :not_found
      end
    end

    private

    def parse_request
      @json = JSON.parse(request.body.read)
    end

    def json_params_valid?
      @json.key?('resource_path') && @json.key?('user') &&
        @json.key?('access_methods') && @json['access_methods'].respond_to?(:[]) &&
        User.exists?(email: @json['user']) &&
        @json['access_methods'].map do |access_method|
          AccessMethod.where('lower(name) = ?', access_method.downcase).exists?
        end.reduce(:&)
    end

    def render_bad_request
      head :bad_request
    end

    def create_access_policy(user, access_method, resource)
      AccessPolicy.create(
        user: user,
        access_method: AccessMethod.find_by(name: access_method.downcase),
        resource: resource
      )
    end

    def resource_path_param
      Resource.normalize_path(params[:resource_path]) if params[:resource_path]
    end
  end
end
