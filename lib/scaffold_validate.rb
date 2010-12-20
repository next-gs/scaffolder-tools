require 'yaml'
require 'scaffolder'
require 'scaffolder/tool'

class ScaffoldValidate < Scaffolder::Tool

  def execute
    scaffold
  end

  def errors
    sequences = scaffold.select{|i| i.entry_type == :sequence}
    sequences.reject{|i| self.class.sequence_errors(i).empty? }
  end

  def print_errors
    if errors.empty?
      ""
    else
      YAML.dump(errors.inject(Hash.new) do |hash,sequence|
        hash[sequence.source] ||= []
        self.class.sequence_errors(sequence).each do |error|
          error.each do |insert|
            hash[sequence.source] << {:open => insert.open,:close => insert.close}
          end
        end
        hash
      end)
    end
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
