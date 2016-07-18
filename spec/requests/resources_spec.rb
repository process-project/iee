require 'rails_helper'

RSpec.describe 'Resources' do
  context 'with user signed in' do
    let(:user) { create(:user, :approved) }
    let(:service) { create(:service) }
    before { login_as(user) }

    describe 'POST /resources' do
      it 'should create a new resource' do
        create(:access_method, name: 'manage')

        expect {
          post '/resources/',
               params: {
                 resource: FactoryGirl.attributes_for(:resource).merge(service_id: service.id)
               }
        }.to change { Resource.count }.by(1)

        expect(response).to redirect_to(resources_path)
      end
    end
  end
end
