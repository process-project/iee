# frozen_string_literal: true

module Liquid
  class CloneRepo < Liquid::Tag
    def initialize(tag_name, repo, tokens)
      super
      @repo = repo
    end

    def render(_context)
      <<~CODE
        export SSH_DOWNLOAD_KEY="#{ssh_download_key}"
        ssh-agent bash -c '
          ssh-add <(echo "$SSH_DOWNLOAD_KEY");
          git clone #{gitlab_clone_url}:#{@repo}'
      CODE
    end

    private

    def ssh_download_key
      File.read(Rails.application.config_for('eurvalve')['git_download_key'])
    end

    def gitlab_clone_url
      Rails.application.config_for('application')['gitlab']['clone_url']
    end
  end
end
