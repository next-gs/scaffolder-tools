require 'scaffolder'

class Scaffolder::Tool
  attr :scaffold

  def initialize(scaffold)
    @scaffold = scaffold
  end

  def run(out=STDOUT,err=STDERR)
    begin
      message = execute
    rescue Exception => e
      err.puts(e.message)
      exit 1
    else
      out.puts(message)
      exit 0
    end
  end

end
