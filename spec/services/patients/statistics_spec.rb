# frozen_string_literal: true

require 'rails_helper'

describe Projects::Statistics do
  let(:user) { create(:user) }
  let(:subject) { described_class.new(nil, user) }

  describe '#create_details' do
    let(:sample) do
      [
        'header',
        ['x', 'Post-op', 'Female'],
        ['y_S_', 'Pre-op', 'Male'],
        ['z-C-', 'post-Op', 'male']
      ]
    end

    it 'tolerates empty input' do
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_return(nil)

      expect { subject.call }.not_to raise_error
    end

    it 'computes gender, site and state ratios based on clinical data report' do
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_return(sample)

      stats = subject.call

      expect(stats[:females]).to eq 1
      expect(stats[:males]).to eq 1
      expect(stats[:no_gender]).to eq 1
      expect(stats[:preop]).to eq 1
      expect(stats[:postop]).to eq 1
      expect(stats[:no_state]).to eq 1
      expect(stats[:berlin]).to eq 0
      expect(stats[:eindhoven]).to eq 1
      expect(stats[:sheffield]).to eq 1
      expect(stats[:no_site]).to eq 1
      expect(stats[:count]).to eq 3
    end

    it 'assumes testing cases as all that have no information in clinical data report' do
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_return(sample)

      subject = described_class.new(create_list(:project, 4), user)
      expect(subject.call[:test]).to eq 1
    end
  end
end
