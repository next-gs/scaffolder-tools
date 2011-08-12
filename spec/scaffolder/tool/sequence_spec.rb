require 'spec_helper'

describe Scaffolder::Tool::Sequence do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  it "should return the description of the tool" do
    desc = "Generate the fasta output for the scaffold"
    described_class.description.should == desc
  end

  describe "execution when correctly instantiated" do

    before(:each) do
      entries = [{:name => 'seq1', :nucleotides => 'ATGC'}]

      @scaffold_file = File.new("scaffold",'w').path
      @sequence_file = File.new("sequence",'w').path

      write_scaffold_file(entries,@scaffold_file)
      write_sequence_file(entries,@sequence_file)
      settings = mock_command_line_settings(@scaffold_file,@sequence_file,{
        :definition => nil,:no => nil})

      tool = described_class.new(settings)
      @output = StringIO.new(tool.execute)
    end

    after(:each) do
      File.delete @scaffold_file, @sequence_file
    end

    it "should return the expected sequence" do
      Bio::FlatFile.auto(@output).first.seq.should == 'ATGC'
    end

  end

end
