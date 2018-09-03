# frozen_string_literal: true

require 'rails_helper'

describe Projects::Create do
  let(:user) { create(:user) }
  let(:stranger) { build(:project, project_name: '{ &*^%$#@![]":;.,<>/?\a stranger in the night}') }

  it 'creates new project in db' do
    webdav = instance_double(Webdav::Client)
    allow(webdav).to receive(:r_mkdir)

    expect { described_class.new(user, build(:project), client: webdav).call }.
      to change { Project.count }.by(1)
  end

  it 'creates project webdav directory' do
    webdav = instance_double(Webdav::Client)
    new_project = build(:project)

    expect(webdav).to receive(:r_mkdir).
      with("test/projects/#{new_project.project_name}/inputs/")
    expect(webdav).to receive(:r_mkdir).
      with("test/projects/#{new_project.project_name}/pipelines/")

    described_class.new(user, new_project, client: webdav).call
  end

  it 'does not create db project when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception

    expect { described_class.new(user, build(:project), client: webdav).call }.
      to_not(change { Project.count })
  end

  it 'does not create webdav dir if db project is invalid' do
    webdav = instance_double(Webdav::Client)
    expect(webdav).not_to receive(:r_mkdir)

    expect(stranger).not_to be_valid
    described_class.new(user, stranger, client: webdav).call
  end

  it 'set error message when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception
    new_project = build(:project)

    described_class.new(user, new_project, client: webdav).call

    expect(new_project.errors[:project_name]).
      to include(I18n.t('activerecord.errors.models.project.create_dav403'))
  end

  def web_dav_with_http_server_exception
    instance_double(Webdav::Client).tap do |webdav|
      allow(webdav).to receive(:r_mkdir).
        and_raise(Net::HTTPServerException.new(403, 'Error'))
    end
  end
end
