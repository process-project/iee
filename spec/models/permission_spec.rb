require 'rails_helper'

RSpec.describe Permission do
  it { should belong_to(:user) }
  it { should belong_to(:group) }
  it { should belong_to(:action) }
  it { should belong_to(:resource) }

  it 'validates action presence' do
    permission = build(:permission, action: nil)

    permission.validate

    expect(permission).to_not be_valid
    expect(permission.errors[:action_id]).to include(I18n.t('missing_action'))
  end

  it 'validates resource presence' do
    permission = build(:permission, resource: nil)

    permission.validate

    expect(permission).to_not be_valid
    expect(permission.errors[:resource_id]).
      to include(I18n.t('missing_resource'))
  end

  it 'group is required when no user' do
    permission = create(:group_permission)

    expect(permission).to be_valid
  end

  it 'user is required when no group' do
    permission = create(:user_permission)

    expect(permission).to be_valid
  end

  it 'requires user or group' do
    user_group_empty = build(:permission)
    user_group_not_empty = build(:permission,
                                 user: build(:user),
                                 group: build(:group))

    user_group_empty.save
    user_group_not_empty.save

    expect(user_group_empty).to_not be_valid
    expect(user_group_not_empty).to_not be_valid
  end
end
