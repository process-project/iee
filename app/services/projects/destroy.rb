# frozen_string_literal: true

module Projects
  class Destroy
    def initialize(_user, project, _options = {})
      @project = project
    end

    def call
      Project.transaction { internal_call }
      !@project.persisted?
    end

    protected

    def internal_call
      @project.destroy
    end
  end
end
