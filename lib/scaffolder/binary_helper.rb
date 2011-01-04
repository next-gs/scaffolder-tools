require 'scaffolder/tool_index'

module Scaffolder::BinaryHelper
  include Scaffolder::ToolIndex

  DEFAULT_TOOL = Scaffolder::Tool::Help

  def select_tool(name)
    tool_exists?(name) ? get_tool(name) : DEFAULT_TOOL
  end

  def determine_tool(settings)
    type = settings.rest.shift
    tool_class = self[type]
    settings[:unknown_tool] = type unless (tool_exists?(type) or type.nil?)
    [tool_class,settings]
  end

end
