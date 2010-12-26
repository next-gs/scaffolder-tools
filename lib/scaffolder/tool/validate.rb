require 'yaml'
require 'scaffolder'
require 'scaffolder/tool'

class Scaffolder::Tool::Validate < Scaffolder::Tool

  def self.description
    "Validate scaffold for overlapping inserts"
  end

  def execute
    bad_sequences = errors
    return if bad_sequences.empty?

    output = bad_sequences.inject(Array.new) do |array, sequence|
      self.class.sequence_errors(sequence).each do |overlaps|
        array << {'sequence-insert-overlap' => {
          'source' => sequence.source,
          'inserts' => overlaps.map do |overlap|
            {'open'  => overlap.open,
            'close'  => overlap.close,
            'source' => overlap.source}
          end
        }}
      end
      array
    end

    YAML.dump(output)
  end

  def errors
    sequences = scaffold.select{|i| i.entry_type == :sequence}
    sequences.reject{|i| self.class.sequence_errors(i).empty? }
  end

  def self.inserts_overlap?(a,b)
    ! (a.position.to_a & b.position.to_a).empty?
  end

  def self.sequence_errors(sequence)
    sequence.inserts.inject(Array.new) do |errors,a|
      sequence.inserts.each do |b|
        next if a.equal?(b)
        errors << [a,b].sort if inserts_overlap?(a,b)
      end
      errors
    end.uniq
  end

end
