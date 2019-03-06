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

  # rubocop:disable Metrics/MethodLength
  def renderer
    context = {
      'jwt_public_key' => jwt_public_key,
      'jwt_key_algorithm' => jwt_key_algorithm,
      'root_url' => root_url,
      'data_sets_api_doc' => data_sets_api_doc,
      'profile_url' => profile_url,
      'user_token' => current_user.token,
      'flows' => flow_definitions,
      'required_files' => required_file_patterns,
      'webdav_docs_url' => webdav_docs_url,
      'computation_statuses' =>  computation_statuses
    }
    MarkdownRenderer.new(context)
  end
  # rubocop:enable Metrics/MethodLength

  def jwt_public_key
    Vapor::Application.config.jwt.public_key.export
  end

  def jwt_key_algorithm
    Vapor::Application.config.jwt.key_algorithm
  end

  def data_sets_api_doc
    Rails.configuration.constants['data_sets']['url'] +
      Rails.configuration.constants['data_sets']['api_doc_path']
  end

  def flow_definitions
    Flow::FLOWS.map do |flow, steps|
      " - **#{flow}**: #{steps.join(' | ')}"
    end.join("\n")
  end

  def required_file_patterns
    DataFileType.pluck(:pattern, :data_type).map do |pattern, data_type|
      "#{Regexp.new(pattern).inspect} = #{data_type}"
    end.join("\n")
  end

  def webdav_docs_url
    Rails.configuration.constants['file_store']['web_dav_base_url']
  end

  def computation_statuses
    Computation.validators_on(:status).select do |validator|
      validator.is_a? ActiveModel::Validations::InclusionValidator
    end.first.options[:in]
  end
end
