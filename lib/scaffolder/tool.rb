require 'scaffolder'
#require 'ftools'

class Scaffolder::Tool

  attr :scaffold_file
  attr :sequence_file
  attr :settings

  def initialize(args,settings)
    @scaffold_file = args.shift
    @sequence_file = args.shift
    @settings = settings
  end

  def run(out=STDOUT,err=STDERR)
    begin
      message = execute
    rescue Exception => e
      err.puts("Error. #{e.message}")
      exit(1)
    else
      out.puts(message)
      exit(0)
    end
  end

  def scaffold
    unless File.exists?(@scaffold_file)
      raise ArgumentError.new("Scaffold file not found: #{@scaffold_file}")
    end
    unless File.exists?(@sequence_file)
      raise ArgumentError.new("Sequence file not found: #{@sequence_file}")
    end
    if File.size(@sequence_file) == 0
      raise ArgumentError.new("Sequence file is empty: #{@sequence_file}")
    end
    if File.size(@scaffold_file) == 0
      raise ArgumentError.new("Scaffold file is empty: #{@scaffold_file}")
    end
    Scaffolder.new(
      YAML.load(File.open(@scaffold_file,'r'){|f| f.read }),
      @sequence_file)
  end

end
