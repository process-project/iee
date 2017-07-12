# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::Versions do
  let(:project) { 'eurvalve/integration-testing' }

  it 'downloads branches and tags from gitlab', gitlab: true do
    branches_and_tags = Gitlab::Versions.new(project).call

    expect(branches_and_tags[:branches].length).to eq 2
    expect(branches_and_tags[:branches]).to include('some_branch')
  end
end
