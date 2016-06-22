module Api
  class ResourcePolicyController < ActionController::Base
    before_filter :authorize_service
    
    before_filter :parse_request, only: :create
    
    before_filter only: :create do
      unless json_params_valid?
        render nothing: true, status: :bad_request
      end
    end
    
    def create
      Resource.transaction do
        resource = Resource.create(service: @service, path: @json["resource_path"])
        user = User.find_by(email: @json["user"])
        @json["access_methods"].each do |access_method|
          AccessPolicy.create(user: user, access_method: AccessMethod.find_by(name: access_method),
            resource: resource)
        end
      end
      
      render nothing: true, status: :created
    end
    
    def index
      result  = { users: [], groups: [], access_methods: [] }
      User.approved.each { |user| result[:users] << user.email }
      Group.all.each { |group| result[:groups] << group.name }
      AccessMethod.all.each { |access_method| result[:access_methods] << access_method.name }
      
      render json: result, status: :ok
    end
    
    private
    
    def authorize_service
      @service = token ? Service.find_by(token: token) : nil
      @service ? nil : unauthorized_response
    end
    
    def parse_request
      @json = JSON.parse(request.body.read)
    end
    
    def json_params_valid?
      @json.has_key?("resource_path") && @json.has_key?("user") &&
        @json.has_key?("access_methods") && @json["access_methods"].respond_to?(:[]) &&
          User.exists?(email: @json["user"]) &&
            @json["access_methods"].map { |access_method| AccessMethod.exists?(name: access_method)}.reduce(:&)
    end
    
    def token
      request.headers["HTTP_X_SERVICE_TOKEN"]
    end
    
    def unauthorized_response
      head :unauthorized, "WWW-Authenticate" => "X-SERVICE-TOKEN header required"
    end
  end
end