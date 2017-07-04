# frozen_string_literal: true

require 'rails_helper'

describe ScriptGenerator do
  it 'inserts active grant id' do
    script = ScriptGenerator.new(build(:pipeline), '<%= grant_id %>').call

    expect(script).to eq Rails.application.config_for('eurvalve')['grant_id']
  end

  it 'inserts upload file curl' do
    patient = create(:patient,
                     data_files: [build(:data_file,
                                        name: 'foo.txt',
                                        data_type: :image)])
    pipeline = create(:pipeline, patient: patient)
    computation = create(:rimrock_computation, pipeline: pipeline)
    data_file = pipeline.data_file(:image)

    script = ScriptGenerator.new(computation,
                                 '<%= stage_in :image, "out.txt" %>').call

    expect(script).to include data_file.url
    expect(script).to include '$SCRATCHDIR/out.txt'
  end

  it 'inserts download file curl' do
    computation = create(:rimrock_computation)
    script = ScriptGenerator.new(computation,
                                 '<%= stage_out "foo.txt", "bar.txt" %>').call

    expect(script).to include '--data-binary'
    expect(script).to include '@foo.txt'
    expect(script).to include File.join(computation.pipeline.working_url, 'bar.txt')
  end

  it 'inserts download file curl with default target file name' do
    computation = create(:rimrock_computation)
    script = ScriptGenerator.new(computation,
                                 '<%= stage_out "dir/foo.txt" %>').call

    expect(script).to include '@dir/foo.txt'
    expect(script).to include File.join(computation.pipeline.working_url, 'foo.txt')
  end

  it 'inserts gitlab ssh download key payload' do
    script = ScriptGenerator.new(create(:rimrock_computation),
                                 '<%= ssh_download_key %>').call

    expect(script).to include 'SSH KEY'
  end

  it 'inserts repository sha to clone' do
    script = ScriptGenerator.new(create(:rimrock_computation),
                                 '<%= revision %>').call

    expect(script).to include 'master'
  end
end
