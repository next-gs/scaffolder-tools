require 'scaffolder/tool_index'

module Scaffolder::BinaryHelper
  include Scaffolder::ToolIndex

  def [](type)
    if tool_exists?(type)
      get_tool(type)
    else
      Scaffolder::Tool::Help
    end
  end

  def determine_tool(settings)
    type = settings.rest.shift
    tool_class = self[type]
    settings[:unknown_tool] = type unless (tool_exists?(type) or type.nil?)
    [tool_class,settings]
  end

end
