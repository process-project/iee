module Api
  class ResourcePolicyController < ActionController::Base
    before_filter :authenticate_service, :parse_request
    
    before_filter only: :create do
      unless @json.has_key?("resource_path") && @json.has_key?("user") &&
          @json.has_key?("access_methods") && @json["access_methods"].respond_to?(:[]) &&
          User.exists?(email: @json["user"])
        render nothing: true, status: :bad_request
        
        next
      end
      
      @json["access_methods"].each do |access_method|
        if !AccessMethod.exists?(name: access_method)
          render nothing: true, status: :bad_request
          
          break
        end
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
    
    private
    
    def authenticate_service
      token = request.headers["HTTP_X_SERVICE_TOKEN"]
      
      if token
        service = Service.find_by(token: token)
        
        if service
            @service = service
            
            return
        end
      end
      
      head :unauthorized, "WWW-Authenticate" => "X-SERVICE-TOKEN header required"
    end
    
    def parse_request
      @json = JSON.parse(request.body.read)
    end
  end
end