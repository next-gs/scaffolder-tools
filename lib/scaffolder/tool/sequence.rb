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
    header = Array.new
    header << opts[:definition] if opts[:definition]
    if opts[:'with-sequence-digest']
      digest = Digest::SHA1.hexdigest(sequence)
      header << "[sha1=#{digest}]"
    end



    header * ' '
  end

end
