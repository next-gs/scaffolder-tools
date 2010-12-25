require 'scaffolder/tool'

class Scaffolder::Tool::Default < Scaffolder::Tool

  def execute
    message = String.new
    if @settings[:unknown_command]
      raise ArgumentError.new(
       "Unknown command '#{@settings[:unknown_command]}'.\nSee 'scaffolder --help'.")
    end
    if @settings[:version]
      message << "scaffolder tool version #{File.read('VERSION').strip}"
    end
    if @settings[:help] || @settings.keys.empty?
      message << <<-MSG
usage: scaffolder [--version] [--help] COMMAND scaffold-file sequence-file
[options]
      MSG
    end
    message
  end

end
