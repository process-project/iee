# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'PDP' do
  context 'as logged in user' do
    let(:user) { create(:user, :approved) }
    let(:service) { create(:service, uri: 'http://localhost', uri_aliases: ['http://alias.pl']) }
    let(:resource) { create(:resource, service: service, name: 'rname') }
    let(:access_method) { create(:access_method, name: 'get') }

    before { login_as(user) }

    it 'returns 200 when user has permission' do
      create(:user_access_policy, user: user, resource: resource, access_method: access_method)

      get api_pdp_index_path,
          params: { uri: resource.uri, access_method: 'get' }

      expect(response.status).to eq(200)
    end

    it 'access method is case insensitive' do
      access_method = create(:access_method, name: 'GET')
      create(:user_access_policy, user: user, resource: resource, access_method: access_method)

      get api_pdp_index_path,
          params: { uri: resource.uri, access_method: 'get' }

      expect(response.status).to eq(200)
    end

    it 'service uri is case insensitive' do
      create(:user_access_policy, user: user, resource: resource, access_method: access_method)

      get api_pdp_index_path,
          params: { uri: resource.uri.upcase, access_method: 'get' }

      expect(response.status).to eq(200)
    end

    it 'returns 403 when user does not have permission' do
      get api_pdp_index_path,
          params: { uri: resource.uri, access_method: 'get' }

      expect(response.status).to eq(403)
    end

    it 'returns 403 for non existing resource' do
      get api_pdp_index_path,
          params: { uri: 'non_existing', access_method: 'get' }

      expect(response.status).to eq(403)
    end

    it 'widlcard at the end should not be default' do
      create(:user_access_policy, user: user, resource: resource, access_method: access_method)

      get api_pdp_index_path,
          params: { uri: "#{resource.uri}/subpath", access_method: 'get' }

      expect(response.status).to eq(403)
    end

    it `returns 200 if another policy with a matching path but different access methods exist` do
      create(:user_access_policy, user: user, resource: resource, access_method: access_method)
      another_access_method = create(:access_method, name: 'post')
      another_mathing_resource = create(:resource,
                                        path: '/.*',
                                        service: service,
                                        resource_type: :global)
      create(:user_access_policy,
             user: user,
             resource: another_mathing_resource,
             access_method: another_access_method)

      get api_pdp_index_path,
          params: { uri: resource.uri, access_method: 'get' }

      expect(response.status).to eq(200)
    end

    context 'missing query params' do
      before do
        create(:user_access_policy,
               user: user, resource: resource, access_method: access_method)
      end

      it 'returns 403 when access_method is missing' do
        get api_pdp_index_path,
            params: { uri: resource.uri }

        expect(response.status).to eq(403)
      end

      it 'returns 403 when uri is missing' do
        get api_pdp_index_path,
            params: { access_method: 'get' }

        expect(response.status).to eq(403)
      end
    end

    context 'resource with regular expressions' do
      let(:resource) { create(:resource, path: '/path/.*', service: service) }

      before do
        create(:user_access_policy,
               user: user, resource: resource, access_method: access_method)
      end

      it 'returns 200 for matching resource' do
        get api_pdp_index_path,
            params: {
              uri: 'http://localhost/path/something',
              access_method: 'get'
            }

        expect(response.status).to eq(200)
      end

      it 'returns 200 for matching resource with uri_alias' do
        get api_pdp_index_path,
            params:  {
              uri: 'http://alias.pl/path/something',
              access_method: 'get'
            }

        expect(response.status).to eq(200)
      end

      it 'returns 403 for not matching resources' do
        get api_pdp_index_path,
            params: {
              uri: 'http://localhost/path2/something',
              access_method: 'get'
            }

        expect(response.status).to eq(403)
      end

      context 'several resources with overlapping regular expressions and different users' do
        let(:resource_2) do
          create(:resource,
                 path: '/path/extra/.*', service: service, resource_type: :global)
        end
        let(:user_2) { create(:user, :approved) }

        before do
          create(:user_access_policy,
                 user: user_2, resource: resource_2,
                 access_method: access_method)
        end

        it 'returns 403 as conflicting access policies exist' do
          get api_pdp_index_path,
              params: {
                uri: 'http://localhost/path/extra/something',
                access_method: 'get'
              }

          expect(response.status).to eq(403)
        end
      end
    end

    context 'path in service uri' do
      let(:webdav) do
        create(:service,
               uri: 'http://localhost:8080/webdav',
               uri_aliases: ['http://alias.pl/webdav'])
      end
      let(:dav_resource) { create(:resource, service: webdav, path: '/') }
      let(:dav_access_method) { create(:access_method, name: 'get') }
      it 'returns 200' do
        create(:user_access_policy,
               user: user, resource: dav_resource, access_method: dav_access_method)
        get api_pdp_index_path,
            params:  {
              uri: 'http://localhost:8080/webdav/',
              access_method: 'get'
            }

        expect(response.status).to eq(200)
      end
    end
  end

  context 'as anonymous' do
    it 'returns 401' do
      get api_pdp_index_path,
          params: { uri: 'some_resource' }

      expect(response.status).to eq(401)
      expect(response.headers['WWW-Authenticate']).
        to eq('Bearer realm="example"')
    end
  end
end
