require 'yaml'
require 'scaffolder'

class ScaffoldValidate

  def initialize(scaffold)
    @scaffold = scaffold
  end

  def errors
    sequences = @scaffold.select{|i| i.entry_type == :sequence}
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

  def self.run(scaffold_file,sequence_file)
    scaffold = Scaffolder.new(YAML.load(File.read(scaffold_file)),sequence_file)
    self.new(scaffold).print_errors
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
