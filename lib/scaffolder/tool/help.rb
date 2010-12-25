require 'scaffolder/tool'

class Scaffolder::Tool::Help < Scaffolder::Tool

  def execute
    raise_for_unknown(@settings[:unknown_command]) if @settings[:unknown_command]

    message = String.new
    message << version if @settings[:version]
    message << help if @settings[:help] || @settings.keys.empty?
    message
  end

  private

  def raise_for_unknown(command)
    msg = "Unknown command '#{command}'.\nSee 'scaffolder --help'."
    raise ArgumentError.new(msg)
  end

  def version
    ver = File.read(File.join(%W|#{File.dirname(__FILE__)} .. .. .. VERSION|)).strip
    "scaffolder tool version #{ver}"
  end

  def help
    <<-MSG.gsub(/^ {6}/, '')
      "usage: scaffolder [--version] [--help] COMMAND scaffold-file sequence-file
      [options]

      Commands:"
    MSG
  end

end
