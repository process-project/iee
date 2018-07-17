# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

RSpec.describe ScriptedStep do
  include GitlabHelper

  subject do
    ScriptedStep.new('rom', 'my/repo', 'repo_file.erb.sh', 'cluster',
                     deployments: %w[cluster cloud])
  end

  let(:pipeline) { create(:pipeline) }

  it_behaves_like 'pipeline step builder'

  context '#config' do
    before { mock_gitlab_versions }

    it 'returns vesions' do
      expect(subject.config[:tags_and_branches]).
        to eq(branches: %w[b1 b2], tags: %w[t1 t2])
    end

    it 'returns deployments' do
      expect(subject.config[:deployments]).
        to eq(%w[cluster cloud])
    end
  end
end
