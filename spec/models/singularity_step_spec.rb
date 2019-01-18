# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

RSpec.describe SingularityStep do
  subject { SingularityStep.new('TestStep', 'shub://', 'vsoch/hello-world', 'latest') }
  let(:pipeline) { create(:pipeline) }

  it_behaves_like 'pipeline step builder'
end
