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

    def public_key
      @pub_key ||= OpenSSL::PKey::EC.new(key).tap { |pk| pk.private_key = nil }
    end
  end
end
