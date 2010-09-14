require 'yaml'
require 'digest/sha1'
require 'scaffolder'

class Scaffold2sequence

  def self.run(args,settings)
    sequence_file = args.pop
    scaffold_file = args.pop

    scaffold = Scaffolder.new(YAML.load(File.read(scaffold_file)),sequence_file)

    s = sequence(scaffold)
    Bio::Sequence.new(s).output(:fasta,:header => header(s,settings))
  end

  def self.sequence(scaffold)
    sequence = scaffold.inject(String.new) do |string,entry|
      string << entry.sequence
    end
  end

  def self.header(sequence,options={})
    header = String.new
    header << options[:definition] + " " if options[:definition]
    unless options[:no][:sequence][:hash]
      header << Digest::SHA1.hexdigest(sequence)
    end
    header
  end

end
