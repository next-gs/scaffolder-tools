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
      contig = Sequence.new(:name => 'seq1', :sequence => 'ATGC')
      scf_file, seq_file = generate_scaffold_files([contig])

      settings = mock_command_line_settings(scf_file.path,seq_file.path,
        {:definition => nil,:no => nil})

      @tool = described_class.new(settings)
    end

    subject do
      StringIO.new(@tool.execute)
    end

    it "should return the expected sequence" do
      Bio::FlatFile.auto(subject).first.seq.should == 'ATGC'
    end

  end

end
