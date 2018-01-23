# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

RSpec.describe WebdavStep do
  subject { WebdavStep.new('segmentation', [:image]) }
  let(:pipeline) { create(:pipeline) }

  it_behaves_like 'pipeline step builder'
end
