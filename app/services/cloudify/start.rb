# frozen_string_literal: true

require 'net/http'
require 'json'
require 'securerandom'

module Cloudify
  class Start < Cloudify::Service
    def initialize(computation)
      super(computation)
    end

    def call
      Cloudify::CreateDeployment.new(computation).call
    end
  end
end
