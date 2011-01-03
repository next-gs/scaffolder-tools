require 'scaffolder'

module Scaffolder::ToolIndex
  require 'scaffolder/tool'

  def get_tool(name)
    tools[normalise(name)]
  end

  def tool_exists?(name)
    tools.keys.include?(normalise(name))
  end

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

  private

  def tool_classes
    Scaffolder::Tool.constants.inject(Array.new) do |array,constant|
      clss = Scaffolder::Tool.const_get(constant)
      array << clss if clss.superclass == Scaffolder::Tool
      array
    end
  end

  def tools
    tool_classes.inject(Hash.new) do |hash,clss|
      hash[clss.to_s.split('::').last.downcase.to_sym] = clss
      hash
    end
  end

  def normalise(name)
    name.to_s.downcase.to_sym if name
  end

end
