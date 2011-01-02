require 'scaffolder/tool'

class Scaffolder::Tool::Help < Scaffolder::Tool

  def self.description
    "Help information for scaffolder commands"
  end

  def execute
    raise_for_unknown(@settings[:unknown_command]) if @settings[:unknown_command]

    command = settings.rest.first
    if command
      raise_for_unknown(command) unless self.class.superclass.known_command?(command)
      man settings.rest.first
    else
      message = String.new
      message << version if @settings[:version]
      message << help if @settings.keys.empty?
      return message
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
    [:help,:sequence,:validate].each do |command|
      string << "  "
      string << command.to_s.ljust(12)
      string << self.class.superclass.commands[command].description + "\n"
    end
    string
  end

  def man(tool)
    man_page = File.join(
      %W|#{File.dirname(__FILE__)} .. .. .. man scaffolder-#{tool}.1.ronn|)

    Kernel.system("ronn -m #{File.expand_path(man_page)}")
  end
end
