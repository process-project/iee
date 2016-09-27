# frozen_string_literal: true
PlgridPolicy = Struct.new(:user, :plgrid) do
  def show?
    user&.plgrid_login
  end
end
