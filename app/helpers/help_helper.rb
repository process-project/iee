module HelpHelper
  def markdown(text)
    unless @markdown_renderer
      @markdown_renderer =
        # see https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
        Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                no_intra_emphasis: true,
                                tables: true,
                                fenced_code_blocks: true,
                                autolink: true,
                                strikethrough: true,
                                lax_html_blocks: true,
                                space_after_headers: true,
                                superscript: true)
    end

    @markdown_renderer.render(text || '').html_safe
  end
end
