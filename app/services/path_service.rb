# frozen_string_literal: true
class PathService
  def self.to_pretty_path(path)
    URI.encode(path.gsub(/\.\*$/, '*'))
  end

  def self.to_path(pretty_path)
    URI.decode(pretty_path).gsub(/\*$/, '.*')
  end
end
