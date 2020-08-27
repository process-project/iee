# frozen_string_literal: true

require 'rails_helper'

describe Projects::Destroy do

  let(:user) { create(:user) }
  let!(:project) { create(:project) }

  it 'remove project from db' do
    expect { described_class.new(user, project).call }.
      to change { Project.count }.by(-1)
  end

  it 'returns true when project is removed' do
    result = described_class.new(user, project).call

    expect(result).to be_truthy
  end

  it 'returns false when project cannot be removed' do
    result = described_class.new(user, project).call
    expect(result).to be_falsy
  end
end
