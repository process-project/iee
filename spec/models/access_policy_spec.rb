# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPolicy do
  it { should belong_to(:user) }
  it { should belong_to(:group) }
  it { should belong_to(:access_method) }
  it { should belong_to(:resource) }

  describe '#access_method' do
    let(:service) { create(:service) }
    let(:access_method) { create(:access_method, service: service) }
    let(:resource) { create(:resource, service: service) }

    it 'validates access_method presence' do
      access_policy = build(:access_policy, access_method: nil)

      access_policy.validate

      expect(access_policy).to_not be_valid
      expect(access_policy.errors[:access_method_id]).to include(I18n.t('missing_access_method'))
    end

    it 'allows global (no-service) access methods' do
      access_policy = build(:user_access_policy)
      expect(access_policy).to be_valid
    end

    it 'allows access methods defined for the related service' do
      access_policy = build(:user_access_policy, resource: resource, access_method: access_method)
      expect(access_policy).to be_valid
    end

    it 'restricts service-scoped access methods' do
      access_policy = build(:user_access_policy, access_method: access_method)
      expect(access_policy).not_to be_valid
      expect(access_policy.errors[:access_method_id]).
        to include I18n.t('different_service_access_method')
    end
  end

  it 'validates resource presence' do
    access_policy = build(:access_policy, resource: nil)

    access_policy.validate

    expect(access_policy).to_not be_valid
    expect(access_policy.errors[:resource_id]).
      to include(I18n.t('missing_resource'))
  end

  it 'group is required when no user' do
    access_policy = create(:group_access_policy)

    expect(access_policy).to be_valid
  end

  it 'user is required when no group' do
    access_policy = create(:user_access_policy)

    expect(access_policy).to be_valid
  end

  it 'requires user or group' do
    user_group_empty = build(:access_policy)
    user_group_not_empty = build(:access_policy,
                                 user: build(:user),
                                 group: build(:group))

    user_group_empty.save
    user_group_not_empty.save

    expect(user_group_empty).to_not be_valid
    expect(user_group_not_empty).to_not be_valid
  end
end
