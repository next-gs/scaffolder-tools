require 'yaml'
require 'digest/sha1'
require 'scaffolder'
require 'scaffolder/tool'

class Scaffolder::Tool::Sequence < Scaffolder::Tool

  def self.description
    "Generate the fasta output for the scaffold"
  end

  def execute
    s = sequence(scaffold)
    Bio::Sequence.new(s).output(:fasta,:header => header(s,@settings))
  end

  private

  def sequence(scaffold)
    scaffold.map{|entry| entry.sequence}.join
  end

  def header(sequence,opts={})
    header = String.new
    header << opts[:definition] + " " if opts[:definition]
    header
  end

end
