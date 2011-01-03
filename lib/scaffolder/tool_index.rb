module Scaffolder::ToolIndex

    def tool_classes
      Scaffolder::Tool.constants.inject(Array.new) do |array,constant|
        clss = Scaffolder::Tool.const_get(constant)
        array << clss if clss.superclass == Scaffolder::Tool
        array
      end
    end

    def commands
      tool_classes.inject(Hash.new) do |hash,clss|
        hash[clss.to_s.split('::').last.downcase.to_sym] = clss
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
