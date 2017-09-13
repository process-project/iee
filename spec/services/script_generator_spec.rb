# frozen_string_literal: true

require 'rails_helper'

describe ScriptGenerator do
  it 'inserts active grant id' do
    script = ScriptGenerator.new(build(:pipeline), '<%= grant_id %>').call

    expect(script).to eq Rails.application.config_for('eurvalve')['grant_id']
  end

  context 'when generating curls' do
    let(:patient) do
      create(
        :patient,
        data_files: [build(
          :data_file,
          name: 'foo.txt',
          data_type: :image
        )]
      )
    end
    let(:pipeline) { create(:pipeline, patient: patient) }
    let(:computation) { create(:rimrock_computation, pipeline: pipeline) }
    let(:data_file) { pipeline.data_file(:image) }

    it 'inserts upload file curl for file type' do
      script = ScriptGenerator.new(
        computation,
        '<%= stage_in data_file_type: :image, filename: "out.txt" %>'
      ).call

      expect(script).to include data_file.url
      expect(script).to include '$SCRATCHDIR/out.txt'
    end

    it 'inserts upload file curl for file path' do
      script = ScriptGenerator.new(
        computation,
        '<%= stage_in path: "path/to/foo.gif", filename: "out.gif" %>'
      ).call

      expected_url = File.join(Webdav::FileStore.url, Webdav::FileStore.path, 'path/to/foo.gif')
      expect(script).to include expected_url
      expect(script).to include '$SCRATCHDIR/out.gif'
    end

    it 'throws ArgumentException on malformed request' do
      generator = ScriptGenerator.new(
        computation,
        '<%= stage_in filename: "out.gif" %>'
      )

      expect { generator.call }.to raise_error(ArgumentError)
    end
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
    script = ScriptGenerator.new(create(:rimrock_computation, revision: 'rev'),
                                 '<%= revision %>').call

    expect(script).to include 'rev'
  end
end