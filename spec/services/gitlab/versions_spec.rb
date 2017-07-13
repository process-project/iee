# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::Versions do
  let(:project) { 'eurvalve/integration-testing' }

  it 'downloads branches and tags from gitlab', gitlab: true do
    branches_and_tags = Gitlab::Versions.new(project).call

    expect(branches_and_tags[:branches]).to contain_exactly 'some_branch', 'master'
    expect(branches_and_tags[:tags]).to eq ['some_tag']
  end

  it 'returns empty list of branches and tags for nonexistent repository', gitlab: true do
    Gitlab.configure do |config|
      config.endpoint = 'http://no.such.url.com/api/v4'
    end

    branches_and_tags = Gitlab::Versions.new(project).call
    expect(branches_and_tags[:branches]).to eq []
    expect(branches_and_tags[:tags]).to eq []
  end

  it 'returns empty list of branches and tags on token validation failure', gitlab: true do
    Gitlab.configure do |config|
      config.private_token = 'foo'
    end

    branches_and_tags = Gitlab::Versions.new(project).call
    expect(branches_and_tags[:branches]).to eq []
    expect(branches_and_tags[:tags]).to eq []
  end
end
