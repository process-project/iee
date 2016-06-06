require 'redcarpet'

class MarkdownRenderer < Redcarpet::Render::HTML
  def initialize(context)
    super
    @context = context
  end

  def preprocess(full_document)
    # full_document is a ActiveSupport::SafeBuffer and must be
    # converted to string so that gsub works properly.
    # see: https://github.com/rails/rails/issues/1734
    full_document = "#{full_document}"

    full_document.gsub(/\$\{([^}]*?)\}/) do
      @context.fetch($1, '')
    end
  end
end
