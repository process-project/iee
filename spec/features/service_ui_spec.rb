# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Service UI' do
  let(:user) { create(:approved_user) }

  before do
    login_as(user)
  end

  scenario 'URI is displayed once' do
    service = create(:service, users: [user])

    visit service_path(service)

    expect(page.all('td', text: service.uri).count).to eq(1)
  end

  scenario 'URI is displayed once (no aliases)' do
    service = create(:service, uri_aliases: [], users: [user])

    visit service_path(service)

    expect(page.all('td', text: service.uri).count).to eq(1)
  end

  scenario 'each URI Alias is displayed once' do
    service = create(:service, users: [user])

    visit service_path(service)

    service.uri_aliases.each do |ua|
      expect(page.all('td', text: ua).count).to eq(1)
    end
  end
end
