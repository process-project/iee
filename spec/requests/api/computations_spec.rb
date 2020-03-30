# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'
Rails.application.load_tasks

RSpec.describe 'Computations' do
  include JsonHelpers

  context 'as logged in user' do
    let(:user) { create(:user, :approved) }

    before do
      login_as(user)
      create(:project, project_name: 'UC2')
      Rake::Task['blueprints:seed'].invoke
    end

    it 'returns valid response on valid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2',
                                                 pipeline_id: 'lofar_pipeline')

      expect(response.status).to eq(200)
      expect(response_json).to include_json(Flow.flows_for(:uc2)['lofar_pipeline'])
    end

    it 'returns 404 on invalid project and valid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar',
                                                 pipeline_id: 'lofar_pipeline')

      expect(response.status).to eq(404)
    end

    it 'returns 404 on valid project and invalid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2',
                                                 pipeline_id: 'foobar')

      expect(response.status).to eq(404)
    end

    it 'returns 404 on invalid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar',
                                                 pipeline_id: 'baz')

      expect(response.status).to eq(404)
    end

    # TODO: start computations - json with chosen parameters
    xit 'starts computation when JSON is proper and returns valid result' do
      post api_project_pipeline_computations_path(project_id: 'UC2',
                                                  pipeline_id: 'lofar_pipeline'),
           params: valid_computation_json,
           as: :json

      expect(response.status).to eq(200)
      expect(response_json).to eq(Pipeline.last.id)
    end

    it 'returns 404 when JSON is proper but project invalid' do
      post api_project_pipeline_computations_path(project_id: 'foo',
                                                  pipeline_id: 'lofar_pipeline'),
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

    xit 'returns valid response on valid project, pipeline and computation' do
      id = create_testing_computation

      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'lofar_pipeline',
                                                id: id.to_s)

      expect(response.status).to eq(200)
      expect(response_json).to include_json(lofar_step: :newz)
    end

    xit 'returns 404 response on valid project, pipeline and invalid computation' do
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'lofar_pipeline',
                                                id: 'foo')

      expect(response.status).to eq(404)
    end

    xit 'returns 404 response on valid project, computation and invalid pipeline' do
      id = create_testing_computation
      get api_project_pipeline_computation_path(project_id: 'UC2',
                                                pipeline_id: 'foo',
                                                id: id)

      expect(response.status).to eq(404)
    end

    xit 'returns 404 response on valid pipeline, computation and invalid project' do
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
      post api_project_pipeline_computations_path(project_id: 'UC2',
                                                  pipeline_id: 'lofar_pipeline'),
           params: valid_computation_json,
           as: :json

      response_json # TODO: check if response_json is just a number string
    end

    # rubocop:disable Metrics/MethodLength
    def valid_computation_json
      {
        'steps' => [{
          'step_name' => 'lofar_step',
          'parameters' => {
            'container_name' => 'lofar/lofar_container',
            'container_tag' => 'latest',
            'hpc' => 'Prometheus',
            'nodes' => '1',
            'cpus' => '24',
            'partition' => 'plgrid',
            'visibility_id' => '1234',
            'avg_freq_step' => '2',
            'avg_time_step' => '4',
            'do_demix' => 't',
            'demix_freq_step' => '2',
            'demix_time_step' => '2',
            'demix_sources' => 'CasA',
            'select_nl' => 't',
            'parset' => 'lba_npp'
          }
        }]
      }
    end
    # rubocop:enable Metrics/MethodLength

    def invalid_computation_json
      { a: 'bar', b: 'foo', c: 3.14 }
    end
  end

  context 'as anonymous' do
    before do
      create(:project, project_name: 'UC2')
    end

    it 'returns 401 on valid project and pipeline' do
      get api_project_pipeline_computations_path(project_id: 'UC2', pipeline_id: 'lofar_pipeline')

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end

    it 'returns 401 on invalid project and valid pipeline' do
      get api_project_pipeline_computations_path(project_id: 'foobar',
                                                 pipeline_id: 'lofar_pipeline')

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
