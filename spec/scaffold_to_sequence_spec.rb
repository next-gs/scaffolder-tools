require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

feature "scaffolder2sequence" do

  scenario "parsing a scaffold with a single sequence" do
    sequence  = OpenStruct.new(:definition => "sequence", :sequence => "ATGC")

    seq_file  = write_sequence_file(sequence)
    scaf_file = write_scaffold_file(
      ['sequence' => {'source' => sequence.definition}])

    out = scaffold2sequence(scaf_file,seq_file)
    out_sequence = out.first

    out_sequence.seq.should == sequence.sequence
    out_sequence.definition.should == Digest::SHA1.hexdigest(sequence.sequence)
  end

  #TODO: Throw errors if required files don't exist
  #TODO: Test exit codes returned

end
