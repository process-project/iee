module Jwt
  class Config
    attr_reader :key, :key_algorithm, :expiration_time, :issuer

    def initialize(conf_hash)
      @key = OpenSSL::PKey::EC.new(
          File.read(conf_hash['key'])
      )
      @key_algorithm = conf_hash['key_algorithm']
      @expiration_time = conf_hash['expiration_time']
      @issuer = conf_hash['issuer']
    end
  end
end
