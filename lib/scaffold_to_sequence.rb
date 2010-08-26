require 'yaml'
require 'digest/sha1'
require 'scaffolder'

class Scaffold2sequence

  def self.run(args,settings)
    sequence_file = args.pop
    scaffold_file = args.pop

    scaffold = Scaffolder.new(YAML.load(File.read(scaffold_file)),sequence_file)
    sequence = scaffold.inject(String.new) do |string,entry|
      string << entry.sequence
    end

    header = String.new
    header << settings[:definition] + " " if settings[:definition]
    header << Digest::SHA1.hexdigest(sequence)

    print Bio::Sequence.new(sequence).output(:fasta,:header => header)
    0
  end

end
