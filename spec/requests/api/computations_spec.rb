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
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'lofar_pipeline')

      expect(response.status).to eq(200)
      expect(response_json).to include_json(Flow.flows_for(:uc2)['lofar_pipeline'])
    end

    it 'returns 404 on invalid project and valid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar', pipeline_id: 'lofar_pipeline')

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

    # TODO start computations - json with chosen parameters
    it 'starts computation when JSON is proper and returns valid result' do
      post api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'lofar_pipeline'),
           params: valid_computation_json,
           as: :json

      expect(response.status).to eq(200)
      expect(response_json).to eq(Pipeline.last.id.to_s)
    end

    it 'returns 404 when JSON is proper but project invalid' do
      post api_project_pipeline_computations_path(project_id: 'foo', pipeline_id: 'lofar_pipeline'),
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
      id = create_testing_computation
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'lofar_pipeline',
                                                id: id) 

      expect(response.status).to eq(200)
      expect(response_json).to include_json(lofar_step: :running)
    end

    it 'returns 404 response on valid project, pipeline and invalid computation' do
      id = create_testing_computation
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'lofar_pipeline',
                                                id: 'foo')

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid project, computation and invalid pipeline' do
      id = create_testing_computation
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'foo',
                                                id: id)

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid pipeline, computation and invalid project' do
      id = create_testing_computation
      get api_project_pipeline_computation_path(project_id: 'foo',
                                                pipeline_id: 'lofar_pipeline',
                                                id: id)

      expect(response.status).to eq(404)
    end

    it 'returns 404 response on valid pipeline and invalid project and computation' do
      get api_project_pipeline_computation_path(project_id: 'bar',
                                                pipeline_id: 'lofar_pipeline',
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

    def create_testing_computation
      post api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'lofar_pipeline'),
           params: valid_computation_json,
           as: :json

      response_json # TODO: check if response_json is just a number string
    end

    def valid_computation_json
      {
        "steps" => [{
          "step_name" => "lofar_step",
          "parameters" => {
            "Container name" => "lofar/lofar_container",
            "Container tag" => "latest",
            "HPC" => "Prometheus",
            "Nodes" => "1",
            "CPUs" => "24",
            "Partition" => "plgrid",
            "LOFAR Visibility ID" => "1234",
            "Average frequency step" => "2",
            "Average time step" => "4",
            "Perform demixer" => "t",
            "Demixer frequency step" => "2",
            "Demixer time step" => "2",
            "Demixer sources" => "CasA",
            "Use NL stations only" => "t",
            "Parameter set" => "lba_npp"
          }
        }]
      }
    end

    def invalid_computation_json
      { a: 'bar', b: 'foo', c: 3.14 }
    end
  end

  context 'as anonymous' do
    it 'returns 401 on valid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'lofar_pipeline')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end

    it 'returns 401 on invalid project and valid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar', pipeline_id: 'lofar_pipeline')

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
