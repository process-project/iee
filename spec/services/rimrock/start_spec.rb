require 'rails_helper'
require 'faraday'

RSpec.describe Rimrock::Start do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  end

  it 'starts computation' do
    user = create(:user, proxy: 'proxy')
    computation = create(:computation, user: user)

    stubs.post('api/jobs') do |env|
      start_request = JSON.parse(env.body)

      expect(start_request['host']).to eq('prometheus.cyfronet.pl')
      expect(start_request['script']).to eq(computation.script)
      expect(start_request['tag']).to eq('vapor')

      [201, {}, '{"job_id":"id", "stdout_path":"out", ' +
                '"stderr_path":"err", "status":"QUEUED"}']
    end

    described_class.new(computation, connection: connection).call
    computation.reload

    expect(computation.stdout_path).to eq('out')
    expect(computation.stderr_path).to eq('err')
    expect(computation.status).to eq('queued')
  end

  it 'fails to start computation' do
    computation = create(:computation)

    stubs.post('api/jobs') do |env|
      [422, {}, '{"status":"error", "exit_code": -1, ' +
                '"standard_output":"stdout", "error_output":"stderr", ' +
                '"error_message": "error_msg"}']
    end

    described_class.new(computation, connection: connection).call
    computation.reload

    expect(computation.status).to eq('error')
    expect(computation.exit_code).to eq(-1)
    expect(computation.standard_output).to eq('stdout')
    expect(computation.error_output).to eq('stderr')
    expect(computation.error_message).to eq('error_msg')
  end

  it 'cannot start already started computation' do
    computation = create(:computation, job_id: 'some_id')

    expect { described_class.new(computation).call }
      .to raise_error(Rimrock::Exception, 'Cannot start computation twice')
  end
end
