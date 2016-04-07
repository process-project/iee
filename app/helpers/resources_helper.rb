module ResourcesHelper
  def resource
    @resource ||= Resource.new
  end
end
