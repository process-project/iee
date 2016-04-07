require 'rails_helper'

RSpec.describe User do
  it { should have_many(:permissions).dependent(:destroy) }

  context 'plgrid login' do
    let(:auth) do
      double(info: double(nickname: 'plguser',
                          email: 'a@b.c',
                          name: 'John Do Doe'))
    end

    it 'creates new user if does not exist' do
      expect { described_class.from_plgrid_omniauth(auth) }.
        to change { User.count }.
        by(1)
    end

    it 'uses auth info to populate user data' do
      user = described_class.from_plgrid_omniauth(auth)

      expect(user.plgrid_login).to eq('plguser')
      expect(user.email).to eq('a@b.c')
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Do Doe')
    end
  end

  context 'jwt' do
    it 'generates and find users using jwt' do
      u = create(:user)

      expect(User.from_token(u.token).id). to eq(u.id)
    end
  end
end
