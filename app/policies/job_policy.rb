# frozen_string_literal: true

JobPolicy = Struct.new(:user, :job) do
  def show?
    user&.admin?
  end
end
