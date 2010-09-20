require 'english'
require 'scaffold_to_sequence'

class ScaffoldStatistics

  def initialize(scaffold)
    @scaffold = scaffold
  end

  def gc_content
    Bio::Sequence::NA.new(build).gc_content.to_f
  end

  def sequence_length
    build.length
  end

  def sequence_sizes
    sizes = sequences.map{|s| s.sequence.length}
    {:smallest => sizes.min, :largest => sizes.max}
  end

  def sequence_count
    sequences.inject(Hash.new(0)) { |hash,seq| hash[seq.name] += 1; hash }
  end

  def insert_count
    sequence_sum{|s| s.inserts.length}
  end

  def gap_count
    build.split(/[^Nn]+/).reject{|s| s.empty? }.length
  end

  def gap_base_pair
    sequence_sum{|i| i.sequence.count('N')}
  end

  def gap_percent
    (gap_base_pair.to_f / sequence_length) * 100 unless sequence_length == 0
  end

  private

  def build
    @build ||= Scaffold2sequence.sequence @scaffold
    @build
  end

  def sequences
    @scaffold.select{|e| e.entry_type == :sequence}
  end

  def sequence_sum
    sequences.inject(0) do |sum,sequence|
      sum += yield(sequence)
    end
  end

end
