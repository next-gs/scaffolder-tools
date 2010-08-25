require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

feature "scaffolder2sequence" do

  scenario "parsing a scaffold with a single sequence" do
    sequence = generate_sequences(1).first

    seq_file  = write_sequence_file(sequence)
    scaf_file = write_scaffold_file(sequence)
    out_sequence = scaffold2sequence(scaf_file,seq_file)

    out_sequence.seq.should == sequence.sequence
    out_sequence.definition.should == Digest::SHA1.hexdigest(sequence.sequence)
  end

  scenario "parsing a scaffold with two sequences" do
    sequences = generate_sequences(2)
    combined = sequences.inject(String.new){|s,seq| s << seq.sequence}

    out_sequence = scaffold2sequence(
      write_scaffold_file(sequences),write_sequence_file(sequences))

    out_sequence.seq.should == combined
    out_sequence.definition.should == Digest::SHA1.hexdigest(combined)
  end

  scenario "parsing a scaffold with two sequences and an unresolved region" do
    sequences = generate_sequences(2).zip(generate_unresolved(2)).flatten
    combined = sequences.inject(String.new){|s,seq| s << seq.sequence}

    out_sequence = scaffold2sequence(
      write_scaffold_file(sequences),write_sequence_file(sequences))

    out_sequence.seq.should == combined
    out_sequence.definition.should == Digest::SHA1.hexdigest(combined)
  end

  #TODO: Throw errors if required files don't exist
  #TODO: Test exit codes returned

end
