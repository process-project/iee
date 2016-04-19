class JobPolicy < Struct.new(:user, :job)
  def show?
    user && user.admin?
  end
end
