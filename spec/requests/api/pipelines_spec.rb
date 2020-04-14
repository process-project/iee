# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Pipelines' do
  include JsonHelpers

  context 'as logged in user' do
    let(:user) { create(:user, :approved) }

    before { login_as(user) }

    it 'returns valid response on valid project' do
      get api_project_pipelines_path(project_id: 'UC2')

      expect(response.status).to eq(200)

      # TODO: Expect proper JSON for preset pipelines instead of this hardcoded value
      expect(response_json).to include_json(
        %w[lofar_pipeline test_flow]
      )
    end

    it 'returns 404 on invalid project' do
      get api_project_pipelines_path(project_id: 'foobar')

      expect(response.status).to eq(404)
    end
  end

  context 'as anonymous' do
    it 'returns 401 on valid project' do
      get api_project_pipelines_path(project_id: 'UC2')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end

    it 'returns 401 on invalid project' do
      get api_project_pipelines_path(project_id: 'foobar')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end
  end
end
