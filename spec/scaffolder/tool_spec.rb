require File.join(File.dirname(__FILE__),'..','spec_helper')

describe Scaffolder::Tool do

  describe "determining the tool type" do

    before(:each) do
      @help_tool = Scaffolder::Tool::Default

      @args = OpenStruct.new({ :rest => %W|type arg1 arg2| })
      @tool = Class.new(described_class)
      described_class.const_set('Type',@tool)
    end

    after(:each) do
      described_class.send(:remove_const,'Type')
    end

    it "return corresponding tool subclass when requested" do
      described_class['type'].should == @tool
    end

    it "should return a hash of tool types" do
      described_class.commands.should be_instance_of(Hash)
      described_class.commands.keys.should include(:type)
      described_class.commands[:type].should == Scaffolder::Tool::Type
    end

    it "return the help tool when passed an unknown command" do
      described_class['unknown-command'].should == @help_tool
    end

    it "return the help tool when passed nil" do
      described_class[nil].should == @help_tool
    end

    it "should fetch the right tool class when requested" do
      tool, args = described_class.determine_tool(@args)
      tool.should == @tool
      args.rest.should == @args.rest[-2..-1]
    end

    it "should fetch the help tool class when no arguments passed" do
      no_args = OpenStruct.new({ :rest => [] })
      tool, args = described_class.determine_tool(no_args)
      tool.should == Scaffolder::Tool::Default
      args.should == no_args
    end

    it "should fetch the help tool class when an invalid argument is passed" do
      args = Hash.new
      args.expects(:rest).returns(['unknown-command'])
      updated_args = args.clone
      updated_args[:unknown_command] = 'unknown-command'

      tool, args = described_class.determine_tool(args)

      tool.should == @help_tool
      args.should == updated_args
    end
  end

  describe "initialisation with attributes" do

    before(:each) do
      @settings = mock_command_line_settings
    end

    subject do
      Scaffolder::Tool.new(@settings)
    end

    its(:scaffold_file){ should ==  @settings.scaffold_file }
    its(:sequence_file){ should ==  @settings.sequence_file }
    its(:settings){ should ==  @settings }
  end

  describe "the run method" do

    before(:all) do
      @settings = mock_command_line_settings
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
      settings = mock_command_line_settings(@scaffold_file,@missing_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file not found: #{@missing_file}")
    end

    it "should raise an error if the sequence file is empty" do
      settings = mock_command_line_settings(@scaffold_file,@empty_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Sequence file is empty: #{@empty_file}")
    end

    it "should raise an error if the scaffold file is missing" do
      settings = mock_command_line_settings(@missing_file,@sequence_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Scaffold file not found: #{@missing_file}")
    end

    it "should raise an error if the scaffold file is empty" do
      settings = mock_command_line_settings(@empty_file,@sequence_file)
      tool = Scaffolder::Tool.new(settings)
      lambda{ tool.scaffold }.should raise_error(ArgumentError,
        "Scaffold file is empty: #{@empty_file}")
    end
  end

  describe "creating the scaffold with the scaffold method" do

    before(:each) do
      entries = [{:name => 'seq1', :nucleotides => 'ATGC'}]

      @scaffold_file = File.new('scaffold','w').path
      @sequence_file = File.new('sequence','w').path
      write_scaffold_file(entries,@scaffold_file)
      write_sequence_file(entries,@sequence_file)
    end

    after(:each) do
      File.delete @scaffold_file, @sequence_file
    end

    subject do
      Scaffolder::Tool.new(
        mock_command_line_settings(@scaffold_file,@sequence_file))
    end

    it "should produce the expected sequence scaffold" do
      subject.scaffold.length.should == 1
      subject.scaffold.first.entry_type.should == :sequence
      subject.scaffold.first.sequence.should == 'ATGC'
    end

  end

end
