# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataFile do
  subject { build(:data_file) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:data_type) }
  it { should validate_presence_of(:project) }

  context '#path' do
    it 'returns relative path for project input' do
      input = build(:data_file,
                    project: build(:project, project_name: '123'), name: 'foo')

      expect(input.path).to eq 'test/projects/123/inputs/foo'
    end

    it 'returns relative path for project pipeline output' do
      project = build(:project, project_name: '123')
      pipeline = build(:pipeline, iid: '1', project: project)
      input = build(:data_file, project: project, output_of: pipeline, name: 'foo')

      expect(input.path).to eq 'test/projects/123/pipelines/1/outputs/foo'
    end

    it 'returns relative path for project pipeline input' do
      project = build(:project, project_name: '123')
      pipeline = build(:pipeline, iid: '1', project: project)
      input = build(:data_file, project: project, input_of: pipeline, name: 'foo')

      expect(input.path).to eq 'test/projects/123/pipelines/1/inputs/foo'
    end
  end

  describe '#content', files: true do
    let(:correct_user) { build(:user, :file_store_user) }
    let(:test_project_with_pipeline) do
      create(:project, :with_pipeline).tap { |p| p.execute_data_sync(correct_user) }
    end
    let(:test_project_with_input) do
      create(:project, project_name: '5678').tap { |p| p.execute_data_sync(correct_user) }
    end

    it 'downloads pipeline file content as a string' do
      expect(test_project_with_pipeline.data_files.first.content(correct_user)).to eq "fake\n"
    end

    it 'downloads project input file content as a string' do
      expect(test_project_with_input.data_files.first.content(correct_user)).to eq "fake\n"
    end
  end

  describe '.data_type' do
    it 'has all values localised' do
      locales = DataFile.data_types.keys.map { |dt| I18n.t "data_file.data_types.#{dt}" }
      expect(locales.any? { |l| l.include? 'translation missing' }).to be_falsey
    end
  end
end
