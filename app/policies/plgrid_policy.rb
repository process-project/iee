class PlgridPolicy < Struct.new(:user, :plgrid)
  def show?
    user && user.plgrid_login
  end
end
