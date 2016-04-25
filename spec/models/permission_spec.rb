require 'rails_helper'

RSpec.describe Permission do
  it { should belong_to(:user) }
  it { should belong_to(:group) }
  it { should belong_to(:action) }
  it { should belong_to(:resource) }

  context "if no action" do
    before {
      allow(subject).to receive(:action).and_return(nil)
      subject.validate
    }
    it {
      should_not subject.valid?
      expect(subject.errors[:action_id]).to include(I18n.t("missing_action"))
    }
  end
  
  context "if no resource" do
    before {
      allow(subject).to receive(:resource).and_return(nil)
      subject.validate
    }
    it {
      should_not subject.valid?
      expect(subject.errors[:resource_id]).to include(I18n.t("missing_resource"))
    }
  end
  
  context 'if no user' do
    before { allow(subject).to receive(:user).and_return(nil) }
    it { should subject.valid? }
  end

  context 'if no group' do
    before { allow(subject).to receive(:group).and_return(nil) }
    it { should subject.valid? }
  end
  
  context "user and group where passed" do
    before { subject.validate }
    it {
      should_not subject.valid?
      expect(subject.errors.keys).to include(:user_id, :group_id)
      expect(subject.errors[:user_id]).to include(I18n.t("either_user_or_group"))
      expect(subject.errors[:group_id]).to include(I18n.t("either_user_or_group"))
    }
  end
end