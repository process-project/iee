# frozen_string_literal: true

require 'rails_helper'

describe Users::Destroy do
  let!(:current_user) { create(:user) }

  it 'removes user from database' do
    user = create(:user)

    expect do
      described_class.new(current_user, user).call
    end.to change { User.count }.by(-1)
  end

  it 'returns :ok when user is removed' do
    result = described_class.new(current_user, create(:user)).call
    expect(result).to eq(:ok)
  end

  it 'fobidden to remove self' do
    expect do
      described_class.new(current_user, current_user).call
    end.to change { User.count }.by(0)
  end

  it 'returns :self when trying to remove self' do
    result = described_class.new(current_user, current_user).call
    expect(result).to eq(:self)
  end
end
