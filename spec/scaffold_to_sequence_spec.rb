require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

feature "scaffolder2sequence" do

  scenario "parsing a scaffold with a single sequence" do
    sequence = generate_sequences(1).first

    seq_file  = write_sequence_file(sequence)
    scaf_file = write_scaffold_file(generate_scaffold(sequence))
    out_sequence = scaffold2sequence(scaf_file,seq_file)

    out_sequence.seq.should == sequence.sequence
    out_sequence.definition.should == Digest::SHA1.hexdigest(sequence.sequence)
  end

  scenario "parsing a scaffold with two sequences" do
    sequences = generate_sequences(2)
    combined = sequences.inject(String.new){|s,seq| s << seq.sequence}

    out_sequence = scaffold2sequence(
      write_scaffold_file(generate_scaffold(sequences)),
      write_sequence_file(sequences))

    out_sequence.seq.should == combined
    out_sequence.definition.should == Digest::SHA1.hexdigest(combined)
  end

  scenario "parsing a scaffold with two sequences and an unresolved region" do
    sequences = generate_sequences(2).zip(generate_unresolved(2)).flatten
    combined = sequences.inject(String.new){|s,seq| s << seq.sequence}

    out_sequence = scaffold2sequence(
      write_scaffold_file(generate_scaffold(sequences)),
      write_sequence_file(sequences))

    out_sequence.seq.should == combined
    out_sequence.definition.should == Digest::SHA1.hexdigest(combined)
  end

  scenario "parsing a scaffold with a single sequence and an insert" do
    sequence = Sequence.new("sequence","ATTACCCTAC")
    insert   = Sequence.new("insert","GGGG")
    expected = 'ATTGGGGCCTAC'

    seq_file  = write_sequence_file(sequence,insert)
    scaffold = generate_scaffold(sequence)
    scaffold.first['sequence']['inserts'] = [
      {'source' => insert.definition, 'start' => 4, 'stop' => 5}
    ]
    scaf_file = write_scaffold_file(scaffold)
    out_sequence = scaffold2sequence(scaf_file,seq_file)

    out_sequence.seq.should == expected
    out_sequence.definition.should == Digest::SHA1.hexdigest(expected)
  end

  scenario "specifying the definition line" do
    sequence = generate_sequences(1).first

    seq_file  = write_sequence_file(sequence)
    scaf_file = write_scaffold_file(generate_scaffold(sequence))
    out_sequence = scaffold2sequence(scaf_file,seq_file,"--definition=seq")

    out_sequence.seq.should == sequence.sequence
    out_sequence.definition.should == "seq " + Digest::SHA1.hexdigest(sequence.sequence)
  end

  scenario "specifying no hash" do
    sequence = generate_sequences(1).first

    seq_file  = write_sequence_file(sequence)
    scaf_file = write_scaffold_file(generate_scaffold(sequence))
    out_sequence = scaffold2sequence(scaf_file,seq_file,
                                     "--no-sequence-hash --definition=seq")

    out_sequence.seq.should == sequence.sequence
    out_sequence.definition.should == "seq"
  end

  #TODO: Throw errors if required files don't exist
  #TODO: Throw errors if files are not in correct format
  #TODO: Test exit codes returned

end
