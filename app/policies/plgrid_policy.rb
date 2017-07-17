# frozen_string_literal: true

PlgridPolicy = Struct.new(:user, :plgrid) do
  def show?
    plgrid_user?
  end

  def destroy?
    plgrid_user?
  end

  private

  def plgrid_user?
    user&.plgrid_login
  end
end
