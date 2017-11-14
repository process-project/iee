# frozen_string_literal: true

module Gitlab
  class Revision
    def initialize(project_name, branch_or_tag_name)
      @project_name = project_name
      @branch_or_tag_name = branch_or_tag_name
    end

    def call
      revision(:branch) || revision(:tag)
    end

    private

    def revision(type)
      Gitlab.send(type, @project_name, @branch_or_tag_name)&.commit&.id
    rescue StandardError
      nil
    end
  end
end
