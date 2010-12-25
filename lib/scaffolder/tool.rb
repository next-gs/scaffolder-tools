require 'scaffolder'

class Scaffolder::Tool

  attr :scaffold_file
  attr :sequence_file
  attr :settings

  class << self

    def commands
      classes = constants.map{|c| const_get(c) }.select{|c| c.superclass == self}
      classes.inject(Hash.new) do |hash,tool|
        hash[tool.to_s.split('::').last.downcase.to_sym] = tool
        hash
      end
    end

    def tool_name(type)
      type.to_s.capitalize
    end

    def known_command?(type)
      constants.include?(tool_name(type))
    end

    def fetch_tool_class(type)
      const_get(tool_name(type))
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

  def initialize(settings)
    @scaffold_file = settings.rest.first
    @sequence_file = settings.rest.last
    @settings = settings
  end

  def run(out=STDOUT,err=STDERR)
    begin
      message = execute
    rescue Exception => e
      err.puts("Error. #{e.message}")
      exit(1)
    else
      out.puts(message) if message
      exit(0)
    end
  end

  def scaffold
    {:Scaffold => @scaffold_file, :Sequence => @sequence_file}.each do |name,file|
      unless File.exists?(file)
        raise ArgumentError.new("#{name} file not found: #{file}")
      end
      if File.size(file) == 0
        raise ArgumentError.new("#{name} file is empty: #{file}")
      end
    end

    Scaffolder.new(YAML.load(File.read(@scaffold_file)),@sequence_file)
  end

  require 'scaffolder/tool/help'
  require 'scaffolder/tool/sequence'
  require 'scaffolder/tool/validate'
end
