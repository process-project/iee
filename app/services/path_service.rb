# frozen_string_literal: true
class PathService
  def self.to_pretty_path(path)
    path.gsub(/\.\*$/, '*')
  end

  def self.to_path(pretty_path)
    pretty_path.gsub(/\*$/, '.*')
  end
end
