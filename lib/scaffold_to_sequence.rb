require 'yaml'
require 'digest/sha1'
require 'scaffolder'

class Scaffold2sequence

  def self.run(args)
    scaffold = Scaffolder.new(YAML.load(File.read(args[0])),args[1])
    sequence = scaffold.inject(String.new) do |string,entry|
      string << entry.sequence
    end
    hash = Digest::SHA1.hexdigest(sequence)
    print Bio::Sequence.new(sequence).output(:fasta,:header => hash)
    0
  end

end
