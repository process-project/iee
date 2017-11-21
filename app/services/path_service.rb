# frozen_string_literal: true

class PathService
  def self.to_pretty_path(path)
    Addressable::URI.escape(path.gsub(/\.\*$/, '*'))
  end

  def self.to_path(pretty_path)
    Addressable::URI.unescape(pretty_path).gsub(/\*$/, '.*')
  end
end
