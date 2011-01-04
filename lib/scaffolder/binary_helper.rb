require 'scaffolder/tool_index'

module Scaffolder::BinaryHelper
  include Scaffolder::ToolIndex

  DEFAULT_TOOL = Scaffolder::Tool::Help

  def select_tool(name)
    tool_exists?(name) ? get_tool(name) : DEFAULT_TOOL
  end

  def remove_first_argument(settings)
    name = settings.rest.shift
  end

  def determine_tool(settings)
    name = remove_first_argument(settings)

    tool_class = select_tool(name)

    if name.nil?
      settings[:empty_args] = true
    elsif not tool_exists?(name)
      settings[:unknown_tool] = name
    end

    [tool_class,settings]
  end

end
