require 'spec_helper'

describe Scaffolder::Tool do

  describe "initialisation with attributes" do

    before(:each) do
      @settings = MockSettings.new(:fake_scf,:fake_seq)
    end

    subject do
      Scaffolder::Tool.new(@settings)
    end

    its(:scaffold_file){ should ==  @settings.scaf_file }
    its(:sequence_file){ should ==  @settings.seq_file }
    its(:settings){ should ==  @settings }
  end

  describe "the run method" do

    before(:all) do
      @settings = MockSettings.new
    end

    before(:each) do
      @message = "output\n"
      @out = StringIO.new
      @err = StringIO.new
    end

    subject do
      Scaffolder::Tool.new(@settings)
    end

    it "should print to standard out when there are no errors" do
      subject.expects(:execute).returns(@message)
      lambda{ subject.run(@out,@err) }.should raise_error
      @err.string.should == ""
      @out.string.should == @message
    end

    it "should print nothing to standard out when there no error and no output" do
      subject.expects(:execute).returns(nil)
      lambda{ subject.run(@out,@err) }.should raise_error
      @err.string.should == ""
      @out.string.should == ""
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

      @missing_file = "file"
    end

    after(:each) do
      FakeFS.deactivate!
    end

    it "should raise an error if the sequence file is missing" do
      settings = MockSettings.new(@scaffold_file,@missing_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file not found: #{@missing_file}")
    end

    it "should raise an error if the sequence file is empty" do
      settings = MockSettings.new(@scaffold_file,@empty_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file is empty: #{@empty_file}")
    end

    it "should raise an error if the scaffold file is missing" do
      settings = MockSettings.new(@missing_file,@sequence_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Scaffold file not found: #{@missing_file}")
    end

    it "should raise an error if the scaffold file is empty" do
      settings = MockSettings.new(@empty_file,@sequence_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Scaffold file is empty: #{@empty_file}")
    end
  end

  describe "creating the scaffold with the scaffold method" do

    before(:each) do
      contig = Sequence.new(:name => 'seq1', :sequence => 'ATGC')
      @scf_file, @seq_file = generate_scaffold_files([contig])
    end

    subject do
      Scaffolder::Tool.new(MockSettings.new(@scf_file.path,@seq_file.path))
    end

    it "should produce the expected sequence scaffold" do
      subject.scaffold.length.should == 1
      subject.scaffold.first.entry_type.should == :sequence
      subject.scaffold.first.sequence.should == 'ATGC'
    end

  end

end
