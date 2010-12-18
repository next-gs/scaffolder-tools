require File.join(File.dirname(__FILE__),'..','spec_helper')

describe Scaffolder::Tool do

  describe "initialisation with attributes" do

    before(:all) do
      @scaffold_file = mock
      @sequence_file = mock
      @settings = mock
    end

    subject do
      Scaffolder::Tool.new([@scaffold_file,@sequence_file],@settings)
    end

    its(:scaffold_file){ should ==  @scaffold_file }
    its(:sequence_file){ should ==  @sequence_file }
    its(:settings){ should ==  @settings }
  end

  describe "the run method" do

    before(:all) do
      @scaffold_file = mock
      @sequence_file = mock
      @settings = mock
    end

    before(:each) do
      @message = "output\n"
      @out = StringIO.new
      @err = StringIO.new
    end

    subject do
      Scaffolder::Tool.new([@scaffold_file,@sequence_file],@settings)
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

  describe "error checking with the scaffold method" do

    before(:each) do
      FakeFS.activate!

      @scaffold_file = File.new('scaffold','w').path
      File.open(@scaffold_file,'w'){|out| out.write "some_content" }

      @sequence_file = File.new('sequence','w').path
      File.open(@sequence_file,'w'){|out| out.write "some_content" }

      @empty_file = File.new('empty_file','w').path
      File.open(@empty_file,'w'){|out| out.write "" }

      @settings = Hash.new
      @missing_file = "file"
    end

    after(:each) do
      FakeFS.deactivate!
    end

    it "should raise an error if the sequence file is missing" do
      tool = Scaffolder::Tool.new([@scaffold_file,@missing_file],@settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file not found: #{@missing_file}")
    end

    it "should raise an error if the sequence file is empty" do
      tool = Scaffolder::Tool.new([@scaffold_file,@empty_file],@settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file is empty: #{@empty_file}")
    end

  end

end
