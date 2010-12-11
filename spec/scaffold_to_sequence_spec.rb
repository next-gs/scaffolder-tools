require File.join(File.dirname(__FILE__),'spec_helper')

describe Scaffold2sequence do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  describe "execution when correctly instantiated" do

    subject do
      scaffold_file,sequence_file = scaffold_and_sequence([{
        'name' => 'seq1', 'nucleotides' => 'ATGC'}])
      settings = Hash.new

      tool = Scaffold2sequence.new([scaffold_file,sequence_file],settings)
      StringIO.new(tool.execute)
    end

    it "should return the expected sequence" do
      Bio::FlatFile.auto(subject).first.seq.should == 'ATGC'
    end

  end

end
