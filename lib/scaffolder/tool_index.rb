module Scaffolder::ToolIndex

    def commands
      classes = Scaffolder::Tool.constants.map{|c| Scaffolder::Tool.const_get(c) }.
        select{|c| c.superclass == Scaffolder::Tool}
      classes.inject(Hash.new) do |hash,tool|
        hash[tool.to_s.split('::').last.downcase.to_sym] = tool
        hash
      end
    end

    def tool_name(type)
      type.to_s.capitalize
    end

    def known_command?(type)
      Scaffolder::Tool.constants.include?(tool_name(type))
    end

    def fetch_tool_class(type)
      Scaffolder::Tool.const_get(tool_name(type))
    end

    def [](type)
      if known_command?(type)
        fetch_tool_class(type)
      else
        Scaffolder::Tool::Help
      end
    end

    def determine_tool(settings)
      type = settings.rest.shift
      tool_class = self[type]
      settings[:unknown_command] = type unless (known_command?(type) or type.nil?)
      [tool_class,settings]
    end

end
