require 'rails_helper'

RSpec.describe UserAudit, type: :model do
  subject { create(:user_audit) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:ip) }
  it { should_not validate_presence_of(:user_agent) }
  it { should_not validate_presence_of(:accept_language) }

  it 'calculates proper CC for the IP' do
    mm_db = MaxMindDB.new(Rails.application.config_for('eurvalve')['maxmind']['db'])
    l = mm_db.lookup subject.ip

    if l.found?
      expect(subject.ip_cc).to eq l.country.iso_code
    else
      expect(subject.ip_cc).to be_nil
    end

  end

  it 'CC is nil for unknown IP (like local)' do
    expect(create(:user_audit, ip: '127.0.0.1').ip_cc).to be_nil
  end

end
