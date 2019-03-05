# frozen_string_literal: true

require 'rails_helper'
require 'faraday'

RSpec.describe Rimrock::Abort do
  include ProxySpecHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, proxy: outdated_proxy) }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  end
  let(:updater) { double.tap { |d| allow(d).to receive_message_chain(:new, :call) } }

  context 'with valid proxy' do
    before(:context) { travel_to valid_proxy_time }
    after(:context) { travel_back }

    it 'aborts active computation' do
      computation = create_computation(status: :running)
      stub_abort_request_for(computation)

      call(computation)

      stubs.verify_stubbed_calls
    end

    it 'change active computation state to aborted' do
      computation = create_computation(status: :running)
      stub_abort_request_for(computation)

      expect { call(computation) }.
        to change { computation.status }.to('aborted')
    end

    it 'notified about status change' do
      computation = create_computation(status: :running)
      stub_abort_request_for(computation)

      expect(updater).to receive_message_chain(:new, :call)

      call(computation)
    end

    it 'does nothing for non running computations' do
      computation = create_computation(status: :finished)
      stub_abort_request_for(computation)

      expect { call(computation) }.
        to_not change { computation.status }
    end
  end

  context 'with invalid proxy' do
    it 'only updates computation status to aborted' do
      computation = create_computation(status: :running)

      expect { call(computation) }.
        to change { computation.status }.to('aborted')
    end
  end

  def stub_abort_request_for(computation)
    stubs.put("api/jobs/#{computation.job_id}") do |env|
      abort_request = JSON.parse(env.body)

      expect(abort_request['action']).to eq('abort')

      [204, {}, nil]
    end
  end

  def create_computation(status:)
    create(:rimrock_computation,
           user: user, status: status, job_id: 'jid')
  end

  def call(computation)
    described_class.new(computation, updater, connection: connection).call
  end
end
