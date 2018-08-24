# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project do
  subject { build(:project) }

  it { should validate_presence_of(:project_name) }
  it { should validate_uniqueness_of(:project_name) }
  it { should allow_value('pn4-_.').for(:project_name) }
  it { should_not allow_value("'{}&%$@#").for(:project_name) }

  describe '#status' do
    it 'returns last pipeline status' do
      project = create(:project)
      p1 = create(:pipeline, project: project)
      create(:computation, status: :error, pipeline: p1)
      p2 = create(:pipeline, project: project)
      create(:computation, status: :finished, pipeline: p2)

      expect(project.status).to eq :success
    end
  end
end
