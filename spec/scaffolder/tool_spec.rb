require File.join(File.dirname(__FILE__),'..','spec_helper')

describe Scaffolder::Tool do

  before(:all) do
    @scaffold_file,@sequence_file = scaffold_and_sequence([{
      'name' => 'seq1', 'nucleotides' => 'ATGC'}])
    @settings = Hash.new
  end

  subject do
    Scaffolder::Tool.new([@scaffold_file,@sequence_file],@settings)
  end

  its(:scaffold_file){ should ==  @scaffold_file }
  its(:sequence_file){ should ==  @sequence_file }
  its(:settings){ should ==  @settings }

  describe "the run method" do

    before(:each) do
      @message = "output\n"

      @out = StringIO.new
      @err = StringIO.new
    end

    it "should print to standard out when there are no errors" do
      subject.expects(:execute).returns(@message)
      lambda{ subject.run(@out,@err) }.should raise_error
      @err.string.should == ""
      @out.string.should == @message
    end

    it "should give a zero exit code when there are no errors" do
      subject.expects(:execute).returns(@message)
      lambda{ subject.run(@out,@err) }.should exit_with_code(0)
    end

    it "should print to standard error when there are errors" do
      subject.expects(:execute).raises(Exception, @message)
      lambda{ subject.run(@out,@err) }.should raise_error
      @out.string.should == ""
      @err.string.should == "Error. #{@message}"
    end

    it "should give a non-zero exit code when there are errors" do
      subject.expects(:execute).raises(Exception, @message)
      lambda{ subject.run(@out,@err) }.should exit_with_code(1)
    end

  end

  describe "the scaffold method" do

    it "should produce the expected sequence scaffold" do
      subject.scaffold.length.should == 1
      subject.scaffold.first.entry_type.should == :sequence
      subject.scaffold.first.sequence.should == 'ATGC'
    end

    it "should raise an error if the sequence file is missing" do
      missing_file = "file"
      tool = Scaffolder::Tool.new([@scaffold_file,missing_file],@settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file not found: #{missing_file}")
    end

    it "should raise an error if the sequence file is empty" do
      empty_file = Tempfile.new('empty_sequence_file').path
      FileUtils.touch(empty_file)
      tool = Scaffolder::Tool.new([@scaffold_file,empty_file],@settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file is empty: #{empty_file}")
    end

  end

end
