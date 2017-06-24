# frozen_string_literal: true
module WebDavSpecHelper
  def stub_webdav
    require 'net/dav'
    allow_any_instance_of(Net::DAV).to receive(:exists?)
    allow_any_instance_of(Net::DAV).to receive(:mkdir)
    allow_any_instance_of(Net::DAV).to receive(:delete)
  end

  def expect_put(client, path, size)
    expect(client).to receive(:put).with(path, anything, size)
  end
end
