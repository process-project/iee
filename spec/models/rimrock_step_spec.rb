# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

RSpec.describe RimrockStep do
  subject { RimrockStep.new('rom', 'my/repo', 'repo_file.erb.sh') }
  let(:pipeline) { create(:pipeline) }

  it_behaves_like 'pipeline step builder'
end
