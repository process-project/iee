# frozen_string_literal: true

require 'net/http'
require 'json'
require 'securerandom'

module Cloud
  class Client
    def initialize(user_token, atmosphere_url)
#      @user_token = user_token
       @user_token = 'eyJhbGciOiJFUzI1NiJ9.eyJuYW1lIjoiUGlvdHIgTm93YWtvd3NraSIsImVtYWlsIjoieW1ub3dha29AY3lmLWtyLmVkdS5wbCIsInN1YiI6IjEzIiwiaXNzIjoiRXVyVmFsdmUgUG9ydGFsIiwiZXhwIjoxNTE4MTg0ODg1fQ.0cELGgveGQlvXFezev4awn8zY5POI0NBi-bPUeoyk-engEtcRGji33D5YE8Bg_2t_PugDDXrwzRFn7BjJz90NQ'
#      @user_token = 'eyJhbGciOiJFUzI1NiJ9.eyJuYW1lIjoiUGlvdHIgTm93YWtvd3NraSIsImVtYWlsIjoieW1ub3dha29AY3lmLWtyLmVkdS5wbCIsInN1YiI6IjEzIiwiaXNzIjoiRXVyVmFsdmUgUG9ydGFsIiwiZXhwIjoxNTE4MTgwNDU3fQ.Vy36tTgBgCtYwKclOamsB_etMsFQ4gMyG8fg7k76PUKl7xmL_OIK80iZJmYmkNh-FYwhyXufQsVadGfP1fW0UA'
#      @user_token = 'eyJhbGciOiJFUzI1NiJ9.eyJuYW1lIjoiUGlvdHIgTm93YWtvd3NraSIsImVtYWlsIjoieW1ub3dha29AY3lmLWtyLmVkdS5wbCIsInN1YiI6IjEzIiwiaXNzIjoiRXVyVmFsdmUgUG9ydGFsIiwiZXhwIjoxNTE3NTgyNDM1fQ.wN9gymf57Uih6VxaRt_b4_6Ub-39bM2FzssUmtR4gzv8Zp2MFdp6L7B0SGZMUQXzuuApk588iFd3piw-kGcgnw'
#      @user_token = 'eyJhbGciOiJFUzI1NiJ9.eyJuYW1lIjoiUGlvdHIgTm93YWtvd3NraSIsImVtYWlsIjoieW1ub3dha29AY3lmLWtyLmVkdS5wbCIsInN1YiI6IjEzIiwiaXNzIjoiRXVyVmFsdmUgUG9ydGFsIiwiZXhwIjoxNTE3NTc4NDY0fQ.YpvEseIlfxVokbE38WHkA_RztN6fkCiQrMsq3RjMUf4sTACiDukga3MERD2gUD136ajePHD-fbcacZOzytOtNA'
      @atmosphere_url = atmosphere_url
      @appliance_type_id = 882 # TODO: parameterize
    end

    def register_initial_config(username, payload)
      # config = "username=#{username};password=#{@user_token};script=#{payload}"
      config = "username=#{username};password=#{@user_token};script=echo 'it works!' > /mnt/filestore/cloud_pipeline_test/result_123.txt"

      puts config

      request = {}
      request[:appliance_configuration_template] = {
          name: "template_#{SecureRandom.hex}",
          payload: config,
          appliance_type_id: @appliance_type_id
      }

      puts request.to_json

      url = URI.parse(@atmosphere_url+'/api/v1/appliance_configuration_templates')
      req = Net::HTTP::Post.new(url.to_s)
      req['Authorization'] = "Bearer #{@user_token}"
      req['Content-Type'] = 'application/json'
      req.body = request.to_json

      res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
        http.request(req)
      }

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @template_id = res_hash['appliance_configuration_template']['id']
    end

    def spawn_appliance(appliance_type_id)

#
#      appliance : {configuration_template_id: "1284", appliance_set_id: "102958", params: {}, name: "foo_deleteme",…}
#      appliance_set_id : "102958"
#      compute_site_ids : ["3"]
#      configuration_template_id : "1284"
#      dev_mode_property_set : {preference_cpu: "0", preference_memory: "0", preference_disk: "0"}
#      preference_cpu : "0"
#      preference_disk : "0"
#      preference_memory : "0"
#      name : "foo_deleteme"
#      params : {}
#      user_key_id : "122"

      if @appliance_set_id && @template_id

        request = {}
        request[:appliance] = {
          appliance_set_id: @appliance_set_id,
          name: "cloud_step_#{SecureRandom.hex}",
          configuration_template_id: @template_id
        }

        url = URI.parse(@atmosphere_url+'/api/v1/appliances')
        req = Net::HTTP::Post.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"
        req['Content-Type'] = 'application/json'
        req.body = request.to_json

        res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
          http.request(req)
        }

        puts res.body

        res_hash = JSON.parse(res.body)

        # Obtain ID from body
        @appliance_id = res_hash['appliance']['id']
      else
        # Not enough data - do nothing
      end

      # url = URI.parse(@atmosphere_url+'/api/v1/appliance_types')
      # req = Net::HTTP::Get.new(url.to_s)
      # req['Authorization'] = "Bearer #{@user_token}"
      #
      # res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
      #   http.request(req)
      # }
      # puts res.body

    end

    def spawn_appliance_set
      request = {}
      request[:appliance_set] = {
        name: 'Cloud pipeline steps',
        priority: 50,
        appliance_set_type: 'workflow',
        optimization_policy: 'manual',
        appliances: []
      }
      simple_req = {}
      simple_req[:appliance_set] = {
        appliance_set_type: 'workflow'
      }

      puts request.to_json
      puts simple_req.to_json

      url = URI.parse(@atmosphere_url+'/api/v1/appliance_sets')
      req = Net::HTTP::Post.new(url.to_s)
      req['Authorization'] = "Bearer #{@user_token}"
      req['Content-Type'] = 'application/json'
      req.body = simple_req.to_json

      res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
        http.request(req)
      }
      puts res.body

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @appliance_set_id = res_hash['appliance_set']['id']

    end

    def cleanup
      delete_appliance_set
      delete_config_template
    end

    def delete_appliance_set
      if @appliance_set_id
        url = URI.parse(@atmosphere_url+'/api/v1/appliance_sets'+@appliance_set_id.to_s)
        req = Net::HTTP::Delete.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"

        res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
          http.request(req)
        }
        puts res.body
      end
    end

    def delete_config_template
      if @template_id
        url = URI.parse(@atmosphere_url+'/api/v1/appliance_configuration_templates'+@template_id.to_s)
        req = Net::HTTP::Delete.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"

        res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
          http.request(req)
        }
        puts res.body
      end
    end

  end
end
