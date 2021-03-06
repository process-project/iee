# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it { should have_many(:user_groups).dependent(:destroy) }
  it { should have_many(:access_policies).dependent(:destroy) }
  it { should have_many(:resource_managers).dependent(:destroy) }
  it { should have_many(:computations) }
  it { should have_many(:service_ownerships).dependent(:destroy) }

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
      expect { described_class.from_plgrid_omniauth(auth).save }.
        to change { User.count }.
        by(1)
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
  end

  describe '#admin?' do
    it 'checks if user is an admin' do
      expect(create(:admin)).to be_admin
      expect(create(:user)).to_not be_admin
    end
  end

  describe '#supervisor?' do
    it 'checks if user is a supervisor' do
      expect(create(:supervisor_user)).to be_supervisor
      expect(create(:user)).to_not be_supervisor
    end
  end

  it 'returns users with submitted Rimrock computations' do
    u1, u2, u3 = create_list(:user, 3)

    create(:rimrock_computation, status: 'new', user: u1)
    create(:rimrock_computation, status: 'finished', user: u1)
    create(:rimrock_computation, status: 'queued', user: u2)
    create(:rimrock_computation, status: 'running', user: u3)
    create(:singularity_computation, status: 'running', user: u1)

    expect(User.with_submitted_computations('RimrockComputation')).to contain_exactly(u2, u3)
  end

  it 'returns supervisors' do
    supervisor_group = build(:group, name: 'supervisor')
    supervisor = create(:user)
    supervisor_group.user_groups.build(user: supervisor, owner: true)
    supervisor_group.save!

    create(:user)

    supervisors = User.supervisors

    expect(supervisors.length).to eq 1
    expect(supervisors.first.id).to eq supervisor.id
  end

  context 'hierarchical groups' do
    let(:user) { create(:user) }

    it 'should return a single group' do
      user.groups << create(:group, name: 'group1')

      expect(user.all_groups.count).to eq 1
      expect(user.all_groups.first.name).to eq 'group1'
    end

    it 'should return a group and its parent' do
      parent = create(:group, name: 'parent')
      user.groups << create(:group, name: 'child', parents: [parent])

      expect(user.all_groups.count).to eq 2
      expect(user.all_groups.map(&:name)).to match_array(%w[parent child])
    end

    it 'should not contain a child group if user belongs to parent' do
      parent = create(:group, name: 'parent')
      create(:group, name: 'child', parents: [parent])
      user.groups << parent

      expect(user.all_groups.count).to eq 1
      expect(user.all_groups.map(&:name)).to match_array(['parent'])
    end
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
