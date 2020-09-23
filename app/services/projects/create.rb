# frozen_string_literal: true

module Projects
  class Create
    def initialize(_user, project, _options = {})
      @project = project
    end

    def call
      Project.transaction { internal_call }
      @project
    end

    protected

    def internal_call
      @project.save
    end
  end
end
