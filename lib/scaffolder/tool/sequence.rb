require 'yaml'
require 'digest/sha1'
require 'scaffolder'
require 'scaffolder/tool'

class Scaffolder::Tool::Sequence < Scaffolder::Tool

  def execute
    s = sequence(scaffold)
    Bio::Sequence.new(s).output(:fasta,:header => header(s,@settings))
  end

  private

  def sequence(scaffold)
    sequence = scaffold.inject(String.new) do |string,entry|
      string << entry.sequence
    end
  end

  def header(sequence,opts={})
    header = String.new
    header << opts[:definition] + " " if opts[:definition]
    unless opts[:no] && opts[:no][:sequence] && opts[:no][:sequence][:hash]
      header << Digest::SHA1.hexdigest(sequence)
    end
    header
  end

end
