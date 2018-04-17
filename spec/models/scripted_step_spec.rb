# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

RSpec.describe ScriptedStep do
  subject { ScriptedStep.new('rom', 'my/repo', 'repo_file.erb.sh', 'cluster') }
  let(:pipeline) { create(:pipeline) }

  it_behaves_like 'pipeline step builder'
end
