$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'fakefs/safe'
require 'tempfile'
require 'mocha'
require 'bio'
require 'scaffolder/test/helpers'
require 'scaffolder'

require 'scaffolder/tool'
require 'scaffold_validate'
require 'scaffold_to_sequence'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require File.expand_path(f)
end

RSpec.configure do |config|
  config.mock_with :mocha

  include Scaffolder::Test::Helpers

  def mock_command_line_settings(scaffold_file = mock, sequence_file = mock)
    settings = mock

    settings.stubs(:rest).returns([scaffold_file,sequence_file])
    settings.stubs(:sequence_file).returns(sequence_file)
    settings.stubs(:scaffold_file).returns(scaffold_file)

    settings
  end

  def generate_sequences(count)
    (1..count).to_a.map do |n|
      { :name => "sequence#{n}",
        :nucleotides => %w|A T G C A T G C|.sort_by{rand}.to_s }
    end
  end

  def generate_scaffold(*entries)
    entries.flatten.inject(Array.new) do |array,entry|
      if entry.definition =~ /sequence/
        array << {'sequence' => {'source' => entry.definition}}
      else
        array << {'unresolved' => {'length' => entry.sequence.length}}
      end
    end
  end

  def scaffold_validate(scaffold_file,sequence_file,*flags)
    cmd = "./bin/scaffold-validate #{flags} #{scaffold_file} #{sequence_file}"
    out = StringIO.new(`#{cmd}`)
    if $? == 0
      out.string
    else
      raise RuntimeError.new("Error executing scaffold-validate\n#{out.string}")
    end
  end

end
