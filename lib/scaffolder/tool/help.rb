require 'scaffolder/tool'

class Scaffolder::Tool::Help < Scaffolder::Tool
  include Scaffolder::ToolIndex

  def self.description
    "Help information for scaffolder commands"
  end

  def execute
    raise_for_unknown(@settings[:unknown_tool]) if @settings[:unknown_tool]

    tool = settings.rest.first
    if tool
      raise_for_unknown(tool) unless tool_exists?(tool)
      man settings.rest.first
    elsif @settings[:version]
      return version
    else
      return help
    end
  end

  private

  def raise_for_unknown(command)
    msg = "Unknown command '#{command}'.\nSee 'scaffolder help'."
    raise ArgumentError.new(msg)
  end

  def version
    ver = File.read(File.join(%W|#{File.dirname(__FILE__)} .. .. .. VERSION|)).strip
    "scaffolder tool version #{ver}"
  end

  def help
    string = <<-MSG.gsub(/^ {6}/, '')
      usage: scaffolder [--version] COMMAND scaffold-file sequence-file
      [options]

      Commands:
    MSG
    [:help,:sequence,:validate].each do |name|
      string << "  "
      string << name.to_s.ljust(12)
      string << tools[name].description + "\n"
    end
    string
  end

  def man(tool)
    man_page = File.join(
      %W|#{File.dirname(__FILE__)} .. .. .. man scaffolder-#{tool}.1.ronn|)

    Kernel.system("ronn -m #{File.expand_path(man_page)}")
  end
end
