# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User do
  it { should have_many(:access_policies).dependent(:destroy) }
  it { should have_many(:computations) }

  context 'plgrid login' do
    let(:auth) do
      double(info: double(nickname: 'plguser',
                          email: 'a@b.c',
                          name: 'John Do Doe',
                          proxy: 'a',
                          proxyPrivKey: 'b',
                          userCert: 'c'))
    end

    let(:auth_no_simple_ca) do
      double(info: double(nickname: 'plguser',
                          email: 'a@b.c',
                          name: 'John Do Doe',
                          proxy: nil,
                          proxyPrivKey: nil,
                          userCert: nil))
    end

    it 'creates new user if does not exist' do
      expect { described_class.from_plgrid_omniauth(auth) }
        .to change { User.count }
        .by(1)
    end

    it 'uses auth info to populate user data' do
      user = described_class.from_plgrid_omniauth(auth)

      expect(user.plgrid_login).to eq('plguser')
      expect(user.email).to eq('a@b.c')
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Do Doe')
      expect(user.proxy).to eq('abc')
    end

    it 'approve user account' do
      user = described_class.from_plgrid_omniauth(auth)

      expect(user).to be_approved
    end

    it 'nil proxy when user does not have simple CA registered' do
      user = described_class.from_plgrid_omniauth(auth_no_simple_ca)

      expect(user.proxy).to be_nil
    end

    it 'connects existing user with plgrid' do
      user = create(:user)

      user.plgrid_connect(auth)

      expect(user.plgrid_login).to eq('plguser')
      expect(user.proxy).to eq('abc')
    end
  end

  context 'jwt' do
    it 'generates and find users using jwt' do
      u = create(:user)

      expect(User.from_token(u.token).id).to eq(u.id)
    end

    it 'includes issuer in token' do
      u = create(:user)

      expect(issuer_from_token(u.token))
        .to eq Vapor::Application.config.jwt.issuer
    end

    it 'includes expiration time in token' do
      u = create(:user)
      time_now = Time.now
      allow(Time).to receive(:now).and_return(time_now)
      expect(expiration_time_from_token(u.token))
        .to eq (time_now.to_i + Vapor::Application.config.jwt.expiration_time)
    end
    context 'token expired' do
      it 'fails with error' do
        u = create(:user)
        time_now_1 = Time.now
        time_now_2 =
          time_now_1 + Vapor::Application.config.jwt.expiration_time + 1
        allow(Time).to receive(:now).and_return(time_now_1, time_now_2)
        expired_token = u.token
        expect { User.from_token(expired_token) }
          .to raise_error(JWT::ExpiredSignature)
      end
    end
  end

  it 'checks if user is an admin' do
    admin_group = create(:group, name: 'admin')
    admin = create(:user, groups: [admin_group])
    non_admin = create(:user)

    expect(admin).to be_admin
    expect(non_admin).to_not be_admin
  end

  it 'returns users with active computations' do
    u1, u2, u3 = create_list(:user, 3)

    create(:computation, status: 'new', user: u1)
    create(:computation, status: 'finished', user: u1)
    create(:computation, status: 'queued', user: u2)
    create(:computation, status: 'running', user: u3)

    expect(User.with_active_computations).to contain_exactly(u2, u3)
  end

  it 'returns supervisors' do
    supervisor_group = create(:group, name: 'supervisor')
    supervisor = create(:user, groups: [supervisor_group])
    create(:user)

    supervisors = User.supervisors

    expect(supervisors.length).to eq 1
    expect(supervisors.first.id).to eq supervisor.id
  end

  private

  def issuer_from_token(enc_token)
    decode_token(enc_token).detect { |el| el.key? 'iss' }.try(:[], 'iss')
  end

  def expiration_time_from_token(enc_token)
    decode_token(enc_token).detect { |el| el.key? 'exp' }.try(:[], 'exp')
  end

  def decode_token(enc_token)
    JWT.decode(
      enc_token, Vapor::Application.config.jwt.key, true,
      algorithm: Vapor::Application.config.jwt.key_algorithm
    )
  end
end
