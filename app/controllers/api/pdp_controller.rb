module Api
  class PdpController < Api::ApplicationController
    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    def permit?
      current_user && resource && policy(resource).permit?(params[:permission])
    end

    def resource
      @resource ||= service&.resources&.
                    where(':path ~ path', path: path)&.first
    end

    def path
      postfix = uri
      postfix[(service.uri.length + 1)..-1]
    end

    def service
      @service ||= Service.find_each do |service|
                     break service if uri.starts_with?(service.uri)
                   end
    end

    def uri
      params[:uri]
    end
  end
end
