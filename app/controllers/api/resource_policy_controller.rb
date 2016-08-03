# frozen_string_literal: true
module Api
  class ResourcePolicyController < ActionController::Base
    before_action :authorize_service

    before_action :parse_request, only: :create

    before_action only: :create do
      render_bad_request unless json_params_valid?
    end

    before_action :check_delete_params, only: :delete

    def create
      Resource.transaction do
        resource = Resource.create(service: @service, path: @json['resource_path'])
        user = User.find_by(email: @json['user'])
        @json['access_methods'].each do |access_method|
          AccessPolicy.create(user: user,
                              access_method: AccessMethod.find_by(name: access_method.downcase),
                              resource: resource)
        end
      end

      head :created
    end

    def index
      init_result
      add_approved_users_emails
      add_groups_names
      add_access_methods_names

      render json: @result, status: :ok
    end

    def add_access_methods_names
      AccessMethod.all.each do |access_method|
        @result[:access_methods] << access_method.name.downcase
      end
    end

    def destroy
      resource = Resource.find_by(path: resource_path_param, service: @service)

      if resource
        resource.destroy
        head :no_content
      else
        head :not_found
      end
    end

    private

    def init_result
      @result = { users: [], groups: [], access_methods: [] }
    end

    def add_approved_users_emails
      User.approved.each { |user| @result[:users] << user.email }
    end

    def add_groups_names
      Group.all.each { |group| @result[:groups] << group.name }
    end

    def authorize_service
      @service = token ? Service.find_by(token: token) : nil
      @service ? nil : unauthorized_response
    end

    def parse_request
      @json = JSON.parse(request.body.read)
    end

    def json_params_valid?
      @json.key?('resource_path') && @json.key?('user') &&
        @json.key?('access_methods') && @json['access_methods'].respond_to?(:[]) &&
        User.exists?(email: @json['user']) &&
        @json['access_methods'].map do |access_method|
          AccessMethod.where('lower(name) = ?',
                             access_method.downcase).exists?
        end.reduce(:&)
    end

    def token
      request.headers['HTTP_X_SERVICE_TOKEN']
    end

    def unauthorized_response
      head :unauthorized, 'WWW-Authenticate' => 'X-SERVICE-TOKEN header required'
    end

    def check_delete_params
      render_bad_request if resource_path_param.nil?
    end

    def render_bad_request
      head :bad_request
    end

    def resource_path_param
      Resource.normalize_path(params[:resource_path]) if params[:resource_path]
    end
  end
end
