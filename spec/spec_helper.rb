require 'ostruct'
require 'tempfile'
require 'digest/sha1'
require 'rubygems'

require 'bio'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'
require 'steak'
require 'factory_girl'

Spec::Runner.configure do |config|

  def write_sequence_file(sequence)
    seq = Bio::Sequence.new(sequence.sequence)
    file = Tempfile.new("sequence").path
    File.open(file,'w') do |tmp|
      tmp.print(seq.output(:fasta,:header => sequence.definition))
    end
    file
  end

  def write_scaffold_file(scaffold)
    file = Tempfile.new("scaffold").path
    File.open(file,'w'){|tmp| tmp.print(YAML.dump(scaffold))}
    file
  end

  def scaffold2sequence(scaffold_file,sequence_file)
    s = StringIO.new `./bin/scaffold2sequence #{scaffold_file} #{sequence_file}`
    if $? == 0
      return Bio::FlatFile.open(Bio::FastaFormat, s)
    else
      raise RuntimeError.new("Error executing scaffolder2sequence\n#{s}")
    end
  end

end
