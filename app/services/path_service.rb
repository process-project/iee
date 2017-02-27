# frozen_string_literal: true
class PathService
  def self.from_path(path)
    PathService.new(path)
  end

  def self.from_pretty_path(pretty_path)
    PathService.new(PathService.convert_to_path(pretty_path))
  end

  def initialize(path)
    @path = path
  end

  def get_path
    @path
  end

  def get_pretty_path
    PathService.convert_to_pretty_path(@path)
  end

  private

  def self.convert_to_path(pretty_path)
    pretty_path.gsub(/\*$/, '.*')
  end

  def self.convert_to_pretty_path(path)
    path.gsub(/\.\*$/, '*')
  end
end
