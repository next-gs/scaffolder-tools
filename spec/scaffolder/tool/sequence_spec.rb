require 'spec_helper'

describe Scaffolder::Tool::Sequence do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  it "should return the description of the tool" do
    desc = "Generate the fasta output for the scaffold"
    described_class.description.should == desc
  end

  describe "command line argument" do

    before do
      cntg = Sequence.new(:name => 'seq1', :sequence => 'ATGC')
      @scf_file, @seq_file = generate_scaffold_files([cntg])
    end

    subject do
      Bio::FastaFormat.new(
        StringIO.new(
          described_class.new(
            MockSettings.new(
              @scf_file.path,
              @seq_file.path,
              settings)).execute).string)
    end

    describe "empty" do

      let(:settings) do
        {}
      end

      it "should set the fasta definition" do
        subject.definition.should == ""
      end

      it "should return the expected sequence" do
        subject.seq.should == 'ATGC'
      end

    end

    describe "--definition" do

      let(:settings) do
        {:definition => 'name'}
      end

      it "should set the fasta definition" do
        subject.definition.should == "name"
      end

      it "should return the expected sequence" do
        subject.seq.should == 'ATGC'
      end

    end

    describe "--with-sequence-digest" do
      let(:settings) do
        {:"with-sequence-digest" => true}
      end

      it "should set the fasta definition" do
        header = "[sha1=627a3d8eb465be91696114803b3410ca92f59cc7]"
        subject.definition.should == header
      end

      it "should return the expected sequence" do
        subject.seq.should == 'ATGC'
      end
    end

  end

end
