require 'faraday'

module Staging
  class Service
    def initialize(uc)
      @connection = meta_connection(uc)
    end

    def mkdir(uc, host_alias, path)
    end

    def rm(uc, host_alias, path)
    end

    def host_aliases(uc)
      @connection.get()
      return host_aliases
    end






    def copy(host_alias, [(dst, src), (dst, src)])
      return track_id
    end

    def move(uc, host_alias, [(dst, src), (dst, src)])
      return track_id
    end

    def status(uc, track_id)
      return status
    end

    def list(uc, host_alias, path)
      return ls_output
    end


    private

    def endpoint_for(uc)
      [entry_endpoints, ports, token]
    end

    def connection(host, port, token)

    end

    def meta_connection(uc, )
      connection
    end
  end
end