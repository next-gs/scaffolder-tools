require File.join(File.dirname(__FILE__),'..','spec_helper')

describe Scaffolder::Tool do

  subject do
    @scaffold = mock
    Scaffolder::Tool.new(@scaffold)
  end

  its(:scaffold){ should ==  @scaffold }

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
      @err.string.should == @message
    end

    it "should give a non-zero exit code when there are errors" do
      subject.expects(:execute).raises(Exception, @message)
      lambda{ subject.run(@out,@err) }.should exit_with_code(1)
    end

  end

end
