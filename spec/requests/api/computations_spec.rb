# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Computations' do
  include JsonHelpers

  context 'as logged in user' do
    # TODO: Create required pipelines and jobs which are now hardcoded
    let(:user) { create(:user, :approved) }

    before { login_as(user) }

    it 'returns valid response on valid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'P1')

      expect(response.status).to eq(200)
      expect(response_json).to include_json(['J1'])
    end

    it 'returns 404 on invalid project and valid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar', pipeline_id: 'P1')

      expect(response.status).to eq(404)
    end

    it 'returns 404 on valid project and invalid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'foobar')

      expect(response.status).to eq(404)
    end

    it 'returns 404 on invalid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar', pipeline_id: 'baz')

      expect(response.status).to eq(404)
    end

    it 'starts computation when JSON is proper and returns valid result' do
      post api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'P1'),
           params: valid_computation_json,
           as: :json

      expect(response.status).to eq(200)
      expect(response_json).to include_json(valid_computation_json)
    end

    it 'returns 404 when JSON is proper but project invalid' do
      post api_project_pipeline_computations_path(project_id: 'foo', pipeline_id: 'P1'),
           params: valid_computation_json,
           as: :json

      expect(response.status).to eq(404)
    end

    it 'returns 404 when JSON is proper but pipeline invalid' do
      post api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'foo'),
           params: valid_computation_json,
           as: :json

      expect(response.status).to eq(404)
    end

    it 'returns 404 when JSON is proper but project and pipeline invalid' do
      post api_project_pipeline_computations_path(project_id: 'foo', pipeline_id: 'bar'),
           params: valid_computation_json,
           as: :json

      expect(response.status).to eq(404)
    end

    it 'returns 400 when JSON is invalid' do
      post api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'P1'),
           params: invalid_computation_json,
           as: :json

      expect(response.status).to eq(400)
    end

    it 'returns valid response on valid project, pipeline and computation' do
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'P1',
                                                id: 'J1')

      expect(response.status).to eq(200)
      expect(response_json).to include_json(id: 'J1', status: 'running')
    end

    it 'returns 404 response on valid project, pipeline and invalid computation' do
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'P1',
                                                id: 'foo')

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid project, computation and invalid pipeline' do
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'foo',
                                                id: 'J1')

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid pipeline, computation and invalid project' do
      get api_project_pipeline_computation_path(project_id: 'foo',
                                                pipeline_id: 'P1',
                                                id: 'J1')

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid pipeline and invalid project and computation' do
      get api_project_pipeline_computation_path(project_id: 'bar',
                                                pipeline_id: 'P1',
                                                id: 'foo')

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid project and invalid pipeline and computation' do
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'bar',
                                                id: 'foo')

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on invalid project, pipeline and computation' do
      get api_project_pipeline_computation_path(project_id: 'baz',
                                                pipeline_id: 'bar',
                                                id: 'foo')

      expect(response.status).to eq(404)
    end

    def valid_computation_json
      { a: 7, b: 'foo', c: 3.14 }
    end

    def invalid_computation_json
      { a: 'bar', b: 'foo', c: 3.14 }
    end
  end

  context 'as anonymous' do
    it 'returns 401 on valid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'P1')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end

    it 'returns 401 on invalid project and valid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar', pipeline_id: 'P1')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end

    it 'returns 401 on valid project and invalid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'foobar')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end

    it 'returns 401 on invalid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar', pipeline_id: 'baz')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end
  end
end
