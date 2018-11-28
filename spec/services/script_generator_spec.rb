# frozen_string_literal: true

require 'rails_helper'

describe ScriptGenerator do
  let(:patient) do
    create(
      :patient,
      case_number: 'case-number',
      data_files: [build(
        :data_file,
        name: 'foo.txt',
        data_type: :image
      )]
    )
  end
  let(:pipeline) { create(:pipeline, patient: patient, iid: 1) }
  let(:computation) { create(:rimrock_computation, pipeline: pipeline, revision: 'rev') }
  let(:data_file) { pipeline.data_file(:image) }

  it 'inserts active grant id' do
    script = ScriptGenerator.new(build(:computation), '{{ grant_id }}').call

    expect(script).to eq Rails.application.config_for('eurvalve')['grant_id']
  end

  context 'when generating curls' do
    it 'inserts upload file curl for file type' do
      script = ScriptGenerator.new(
        computation,
        '{% stage_in image out.txt %}'
      ).call

      expect(script).to include data_file.url
      expect(script).to include '$SCRATCHDIR/out.txt'
    end

    it 'adds comment when input file is not found' do
      script = ScriptGenerator.new(
        computation,
        '{% stage_in provenance %}'
      ).call

      expect(script).to include 'could not be found'
    end

    it 'inserts upload file curl for file path' do
      script = ScriptGenerator.new(
        computation,
        '{% stage_in path/to/foo.gif out.gif %}'
      ).call

      expected_url = File.join(Webdav::FileStore.url, Webdav::FileStore.path, 'path/to/foo.gif')
      expect(script).to include expected_url
      expect(script).to include '$SCRATCHDIR/out.gif'
    end

    it 'add --fail flag for download' do
      computation = create(:rimrock_computation)
      script = ScriptGenerator.new(computation,
                                   '{% stage_in dir/foo.txt %}').call

      expect(script).to include '--fail'
    end
  end

  it 'inserts download file curl' do
    computation = create(:rimrock_computation)
    script = ScriptGenerator.new(computation,
                                 '{% stage_out foo.txt %}').call

    expect(script).to include '--data-binary'
    expect(script).to include '@foo.txt'
    expect(script).to include File.join(computation.pipeline.outputs_url, 'foo.txt')
  end

  it 'inserts download file curl with default target file name' do
    computation = create(:rimrock_computation)
    script = ScriptGenerator.new(computation,
                                 '{% stage_out dir/foo.txt %}').call

    expect(script).to include '@dir/foo.txt'
    expect(script).to include File.join(computation.pipeline.outputs_url, 'foo.txt')
  end

  it 'inserts repository sha to clone' do
    script = ScriptGenerator.new(create(:rimrock_computation, revision: 'rev'),
                                 '{{ revision }}').call

    expect(script).to include 'rev'
  end

  it 'inserts clone repo command' do
    script = ScriptGenerator.new(create(:rimrock_computation, revision: 'rev'),
                                 '{% clone_repo org/repo.git %}').call

    expect(script).to include 'export SSH_DOWNLOAD_KEY="SSH KEY'
    expect(script).to include 'git clone git@gitlab-test.com:org/repo.git'
  end

  it 'inserts ansys license server configuration' do
    script = ScriptGenerator.new(create(:rimrock_computation, revision: 'rev'),
                                 '{{ setup_ansys_licenses }}').call

    expect(script).to include 'export ANSYSLI_SERVERS=ansys-servers'
    expect(script).to include 'export ANSYSLMD_LICENSE_FILE=ansys-license-file'
  end

  it 'inserts pipeline identifier' do
    script = ScriptGenerator.new(computation, '{{ pipeline_identifier }}').call

    expect(script).to eq 'case-number-1'
  end

  it 'inserts patient case_number' do
    script = ScriptGenerator.new(computation, '{{ case_number }}').call

    expect(script).to eq 'case-number'
  end

  it 'generates user token' do
    script = ScriptGenerator.new(computation, '{{ token }}').call

    expect(script.size).not_to be 0
  end

  it 'inserts user email' do
    script = ScriptGenerator.new(computation, '{{ email }}').call

    expect(script).to eq pipeline.user.email
  end

  it 'inserts pipeline mode' do
    script = ScriptGenerator.new(computation, '{{ mode }}').call

    expect(script).to eq 'automatic'
  end
end
