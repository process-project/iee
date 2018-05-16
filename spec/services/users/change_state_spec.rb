# frozen_string_literal: true

require 'rails_helper'

describe Users::ChangeState do
  let!(:current_user) { create(:user) }

  it 'updates user status' do
    user = create(:user)

    described_class.new(current_user, user, 'blocked').call

    expect(user.reload.state).to eq('blocked')
  end

  it 'returns :ok when user is removed' do
    result = described_class.new(current_user, create(:user), 'blocked').call
    expect(result).to eq(:ok)
  end

  it 'returns :block_self when trying to block self' do
    result = described_class.new(current_user, current_user, 'blocked').call
    expect(result).to eq(:block_self)
  end
end
