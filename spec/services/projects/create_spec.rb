# frozen_string_literal: true

require 'rails_helper'

describe Projects::Create do
  let(:user) { create(:user) }
  let(:stranger) { build(:project, project_name: '{ &*^%$#@![]":;.,<>/?\a stranger in the night}') }

  it 'creates new project in db' do
    expect { described_class.new(user, build(:project)).call }.
      to change { Project.count }.by(1)
  end
end
