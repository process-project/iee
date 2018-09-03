# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectsHelper do
  describe '#computation_progress' do
    let(:pipeline) { create(:pipeline) }
    let(:computation) do
      create_list(:computation, 4, pipeline: pipeline)[1]
    end

    it 'correctly computes progress bar offset and width' do
      tag = computation_progress(computation, 1)
      expect(tag).to include 'width: 25.0%'
      expect(tag).to include 'margin-left: 25.0%'
    end
  end
end
