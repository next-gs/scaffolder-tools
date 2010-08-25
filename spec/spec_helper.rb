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

  Sequence = Struct.new(:definition,:sequence)

  def generate_sequences(count)
    (1..count).to_a.map do |n|
      Sequence.new("sequence#{n}",%w|A T G C A T G C|.sort_by{rand}.to_s)
    end
  end

  def generate_unresolved(count)
    (1..count).to_a.map do |n|
      Sequence.new("unresolved#{n}",'NNNNN')
    end
  end

  def write_sequence_file(*sequences)
    file = Tempfile.new("sequence").path
    File.open(file,'w') do |tmp|
      sequences.flatten.each do |sequence|
        seq = Bio::Sequence.new(sequence.sequence)
        tmp.print(seq.output(:fasta,:header => sequence.definition))
      end
    end
    file
  end

  def write_scaffold_file(*entries)
    scaffold = entries.flatten.inject(Array.new) do |array,entry|
      if entry.definition =~ /sequence/
        array << {'sequence' => {'source' => entry.definition}}
      else
        array << {'unresolved' => {'length' => entry.sequence.length}}
      end
    end
    file = Tempfile.new("scaffold").path
    File.open(file,'w'){|tmp| tmp.print(YAML.dump(scaffold))}
    file
  end

  def scaffold2sequence(scaffold_file,sequence_file)
    s = StringIO.new `./bin/scaffold2sequence #{scaffold_file} #{sequence_file}`
    if $? == 0
      return Bio::FlatFile.open(Bio::FastaFormat, s).first
    else
      raise RuntimeError.new("Error executing scaffolder2sequence\n#{s}")
    end
  end

end
