module StagingIn
	require 'net/http'
	require 'json'
	class DynamicEndpoint
		def initialize
      @http = Net::HTTP.new(infrastructure_host, infrastructure_port)
		end
		
		def get_query_endpoint
		  req = Net::HTTP::Get.new(infrastructure_path,
		                           'x-access-token' => lobcder_api_infrastructure_access_token)
		  response = @http.request(req)

		  endpoint = {}
		  JSON.parse(response.body).each do |element|
		    if element['type'] == 'query' # and maybe check a name also (in the future)
		      endpoint['staging_in_host'] = element['host']
		      endpoint['staging_in_port'] = element['ports'].first
		    elsif element['type'] == 'token'
		      endpoint['token_header'] = element['header']
		      endpoint['lobcder_api_access_token'] = element['value']
		    end
		  end

		  return endpoint
		end

		private

		def infrastructure_host
	      Rails.application.config_for('process')['staging_in']['infrastructure_host']
	    end

	    def infrastructure_port
	      Rails.application.config_for('process')['staging_in']['infrastructure_port']
	    end

	    def infrastructure_path
	      Rails.application.config_for('process')['staging_in']['infrastructure_path']
	    end

	    def lobcder_api_infrastructure_access_token
	      Rails.application.config_for('process')['staging_in']['lobcder_api_infrastructure_access_token']
	    end
	end
end