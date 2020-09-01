# frozen_string_literal: true

require 'markdown_renderer'

module HelpHelper
  def markdown(text)
    @markdown_renderer ||=
      # see https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
      Redcarpet::Markdown.new(renderer,
                              no_intra_emphasis: true, tables: true,
                              fenced_code_blocks: true,
                              autolink: true, strikethrough: true,
                              lax_html_blocks: true,
                              space_after_headers: true,
                              superscript: true)

    # we can disable cop because Markdown render method ensures its output is html safe.
    # rubocop:disable Rails/OutputSafety
    @markdown_renderer.render(text || '').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  private

  def renderer
    context = {
      'jwt_public_key' => jwt_public_key,
      'jwt_key_algorithm' => jwt_key_algorithm,
      'root_url' => root_url,
      # 'data_sets_api_doc' => data_sets_api_doc
    }
    MarkdownRenderer.new(context)
  end

  def jwt_public_key
    Vapor::Application.config.jwt.public_key.export
  end

  def jwt_key_algorithm
    Vapor::Application.config.jwt.key_algorithm
  end
end
