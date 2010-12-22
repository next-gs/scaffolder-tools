require 'scaffolder'

class Scaffolder::Tool

  attr :scaffold_file
  attr :sequence_file
  attr :settings

  class << self

    def [](type)
      const_get(type.capitalize)
    end

    def determine_tool(settings)
      tool_class = self[settings.rest.shift]
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

  require 'scaffolder/tool/sequence'
  require 'scaffolder/tool/validate'
end
