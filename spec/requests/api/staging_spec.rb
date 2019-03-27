# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Staging API' do
  let(:auth_header) { { 'x-staging-token' => 'token' } }

  it 'returns unauthorized when staging token is not set in env' do
    mock_staging_token_env(nil)

    post api_staging_path, headers: auth_header

    expect(response.status).to eq(401)
  end

  it 'returns unauthorized when wrong token' do
    mock_staging_token_env('secret')

    post api_staging_path, headers: auth_header

    expect(response.status).to eq(401)
  end

  context 'authorized request' do
    before { mock_staging_token_env('token') }

    it 'returns OK' do
      pipeline = create(:pipeline, flow: 'staging_in_placeholder_pipeline')
      computation = create(:staging_in_computation, pipeline: pipeline)
      json_body = { status: { id: computation.id, status: 'done' },
                    details: { timestamp: '2019-03-13T08:48:03.927Z',
                               time: '111598' } }

      post api_staging_path, headers: auth_header, as: :json, params: json_body

      expect(response.status).to eq(204)
    end
  end

  def mock_staging_token_env(value)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('STAGING_SECRET').and_return(value)
  end
end
