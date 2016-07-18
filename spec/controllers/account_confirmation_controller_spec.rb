require 'rails_helper'

RSpec.describe AccountConfirmationController, type: :controller do
  it "should not allow a supervisor to block himself" do
    user = create(:supervisor_user)
    sign_in(user)

    put :block,
        params: { id: user.id }

    expect(response).to redirect_to(account_confirmations_index_path)
    expect(flash[:alert]).to eq(I18n.t("cannot_block_itself"))
  end
end
