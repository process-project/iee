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
    let(:computation) { create(:scripted_computation, pipeline: pipeline, deployment: 'cluster') }
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

    it 'add --fail flag when download is not optional' do
      computation = create(:scripted_computation)
      script = ScriptGenerator.new(computation,
                                   '<%= stage_in path: "dir/foo.txt" %>').call

      expect(script).to include '--fail'
    end

    it 'does not add --fail flag when download is optional' do
      computation = create(:scripted_computation)
      script = ScriptGenerator.
               new(computation,
                   '<%= stage_in path: "dir/foo.txt", optional: true%>').call

      expect(script).to_not include '--fail'
    end

    it 'throws ArgumentException on malformed request' do
      generator = ScriptGenerator.new(
        computation,
        '<%= stage_in filename: "out.gif" %>'
      )

      expect { generator.call }.to raise_error(ArgumentError)
    end

    it 'inserts case number of the patient' do
      script = ScriptGenerator.new(computation, '<%= patient.case_number %>').call

      expect(script).to include(patient.case_number)
    end
  end

  it 'inserts download file curl' do
    computation = create(:scripted_computation)
    script = ScriptGenerator.new(computation,
                                 '<%= stage_out "foo.txt", "bar.txt" %>').call

    expect(script).to include '--data-binary'
    expect(script).to include '@foo.txt'
    expect(script).to include File.join(computation.pipeline.outputs_url, 'bar.txt')
  end

  it 'inserts download file curl with default target file name' do
    computation = create(:scripted_computation)
    script = ScriptGenerator.new(computation,
                                 '<%= stage_out "dir/foo.txt" %>').call

    expect(script).to include '@dir/foo.txt'
    expect(script).to include File.join(computation.pipeline.outputs_url, 'foo.txt')
  end

  it 'inserts gitlab ssh download key payload' do
    script = ScriptGenerator.new(create(:scripted_computation),
                                 '<%= ssh_download_key %>').call

    expect(script).to include 'SSH KEY'
  end

  it 'inserts repository sha to clone' do
    script = ScriptGenerator.new(create(:scripted_computation, revision: 'rev'),
                                 '<%= revision %>').call

    expect(script).to include 'rev'
  end

  it 'inserts gitlab clone url' do
    script = ScriptGenerator.new(create(:scripted_computation, revision: 'rev'),
                                 'git clone <%= gitlab_clone_url %>:org/repo.git').call

    expect(script).to include 'git clone git@gitlab-test.com:org/repo.git'
  end

  it 'inserts clone repo command' do
    script = ScriptGenerator.new(create(:scripted_computation, revision: 'rev'),
                                 '<%= clone_repo("org/repo.git") %>').call

    expect(script).to include 'export SSH_DOWNLOAD_KEY="SSH KEY'
    expect(script).to include 'git clone git@gitlab-test.com:org/repo.git'
  end

  it 'inserts ansys license server configuration' do
    script = ScriptGenerator.new(create(:scripted_computation, revision: 'rev'),
                                 '<%= setup_ansys_licenses %>').call

    expect(script).to include 'export ANSYSLI_SERVERS=ansys-servers'
    expect(script).to include 'export ANSYSLMD_LICENSE_FILE=ansys-license-file'
  end

  it 'inserts pipeline identifier' do
    patient = create(:patient, case_number: 'case-number')
    pipeline = create(:pipeline, patient: patient, iid: 1)
    computation = create(:scripted_computation, pipeline: pipeline)

    script = ScriptGenerator.new(computation, '<%= pipeline_identifier %>').call

    expect(script).to include 'case-number-1'
  end

  it 'inserts patient case_number' do
    patient = create(:patient, case_number: 'case-number')
    pipeline = create(:pipeline, patient: patient, iid: 1)
    computation = create(:scripted_computation, pipeline: pipeline)

    script = ScriptGenerator.new(computation, '<%= case_number %>').call

    expect(script).to include 'case-number'
  end
end
