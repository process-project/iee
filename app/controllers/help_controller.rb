# frozen_string_literal: true
class HelpController < ApplicationController
  def index
    help_payload = File.read(Rails.root.join('doc', 'README.md'))

    # Prefix Markdown links with `help/` unless they already have been
    # See http://rubular.com/r/nwwhzH6Z8X
    @help_index = help_payload.gsub(%r{(\]\()(?!help/)([^\)\(]+)(\))}, '\1help/\2\3')
  end

  def show
    @category = clean_path_info(path_params[:category])
    @file = path_params[:file]

    path = File.join(Rails.root, 'doc', @category, "#{@file}.md")
    if File.exist?(path)
      @markdown = File.read(path)
    else
      render 'errors/not_found.html.haml', layout: 'errors', status: 404
    end
  end

  private

  def path_params
    params.require(:category)
    params.require(:file)

    params
  end

  PATH_SEPS = Regexp.union(*[::File::SEPARATOR, ::File::ALT_SEPARATOR].compact)

  # Taken from ActionDispatch::FileHandler
  # Cleans up the path, to prevent directory traversal outside the doc folder.
  def clean_path_info(path_info)
    parts = path_info.split(PATH_SEPS).reject { |p| p.empty? || p == '.' }

    clean = []

    # Walk over each part of the path
    parts.each do |part|
      # Turn `one/two/../` into `one` or add simple folder names to the clean path.
      part == '..' ? clean.pop : clean << part
    end

    # If the path was an absolute path (i.e. `/` or `/one/two`),
    # add `/` to the front of the clean path.
    clean.unshift '/' if parts.empty? || parts.first.empty?

    # Join all the clean path parts by the path separator.
    ::File.join(*clean)
  end
end
