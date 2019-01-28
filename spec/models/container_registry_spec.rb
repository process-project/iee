# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContainerRegistry, type: :model do
  it { should_not allow_value('qwe').for(:registry_url) }
  it { should_not allow_value('shub://192.168.100.100').for(:registry_url) }
  it { should_not allow_value('shub://192..168.100.100').for(:registry_url) }
  it { should_not allow_value('shub://192.168.100.1040').for(:registry_url) }

  it { should allow_value('shub://').for(:registry_url) }
  it { should allow_value('shub://192.168.0.1/').for(:registry_url) }
  it { should allow_value('shub://192.168.100.100/').for(:registry_url) }
end
