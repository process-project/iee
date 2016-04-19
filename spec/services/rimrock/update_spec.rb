require 'rails_helper'
require 'faraday'

RSpec.describe Rimrock::Update do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  end

  let(:user) { create(:user, proxy: 'proxy') }

  it 'do nothing when user does not have active jobs' do
    create(:computation, status: 'finished', user: user)

    expect(connection).to_not receive(:get)

    described_class.new(user, connection: connection).call
  end

  it 'asks about jobs when user has active computations' do
    create(:computation, status: 'finished', user: user)
    c1 = create(:computation, status: 'queued', job_id: 'job1', user: user)
    c2 = create(:computation, status: 'queued', job_id: 'job2', user: user)

    stubs.get('api/jobs') do |env|
      [200, {}, '[{"job_id": "job1", "status": "FINISHED"},
                  {"job_id": "job2", "status": "RUNNING"}]']
    end

    described_class.new(user, connection: connection).call
    c1.reload
    c2.reload

    expect(c1.status).to eq('finished')
    expect(c2.status).to eq('running')
  end

  it 'logs when error updating computations' do
    create(:computation, status: 'queued', job_id: 'job1', user: user)

    stubs.get('api/jobs') do |env|
      [500, {}, 'error details']
    end

    expect(Rails.logger).to receive(:warn).
      with(I18n.t('rimrock.internal',
                  user: user.name, details: 'error details'))

    described_class.new(user, connection: connection).call
  end
end
