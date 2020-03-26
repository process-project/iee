# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Projects' do
  include JsonHelpers

  context 'as logged in user' do
    let(:user) { create(:user, :approved) }

    before { login_as(user) }

    it 'returns valid response' do
      get api_projects_path

      expect(response.status).to eq(200)
      expect(response_json).to include_json(["UC1","UC2","UC3","UC4","UC5"])
    end
  end

  context 'as anonymous' do
    it 'returns 401' do
      get api_projects_path

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end
  end
end
