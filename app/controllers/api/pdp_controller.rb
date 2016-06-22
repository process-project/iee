module Api
  class PdpController < Api::ApplicationController
    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    #policies of all matching resources must allow for access and at least one policy has to exist
    def permit?
      resources = service&.resources&.where(':path ~ path', path: path)
      
      if resources&.any?
        resources.each do |resource|
          if !policy(resource).permit?(params[:access_method])
            return false
          end
        end
      else
        return false
      end
      
      return true
    end

    def path
      postfix = params[:uri]
      postfix[(service.uri.length + 1)..-1]
    end

    def service
      Service.find_each do |service|
        break service if params[:uri].starts_with?(service.uri)
      end
    end
  end
end
