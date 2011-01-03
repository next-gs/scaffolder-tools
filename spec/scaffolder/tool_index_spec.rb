require File.join(File.dirname(__FILE__),'..','spec_helper')

describe Scaffolder::ToolIndex do

  before(:each) do
    @help_tool = Scaffolder::Tool::Help

    @args = OpenStruct.new({ :rest => %W|type arg1 arg2| })
    @tool = Class.new(Scaffolder::Tool)
    Scaffolder::Tool.const_set('Type',@tool)
  end

  after(:each) do
    Scaffolder::Tool.send(:remove_const,'Type')
  end

  subject do
    object = Object.new
    object.extend described_class
    object
  end

  it "return corresponding tool subclass when requested" do
    subject['type'].should == @tool
  end

  it "should return a hash of tool types" do
    subject.commands.should be_instance_of(Hash)
    subject.commands.keys.should include(:type)
    subject.commands[:type].should == Scaffolder::Tool::Type
  end

  it "return the help tool when passed an unknown command" do
    subject['unknown-command'].should == @help_tool
  end

  it "return the help tool when passed nil" do
    subject[nil].should == @help_tool
  end

  it "should fetch the right tool class when requested" do
    tool, args = subject.determine_tool(@args)
    tool.should == @tool
    args.rest.should == @args.rest[-2..-1]
  end

  it "should fetch the help tool class when no arguments passed" do
    no_args = OpenStruct.new({ :rest => [] })
    tool, args = subject.determine_tool(no_args)
    tool.should == Scaffolder::Tool::Help
    args.should == no_args
  end

  it "should fetch the help tool class when an invalid argument is passed" do
    args = Hash.new
    args.expects(:rest).returns(['unknown-command'])
    updated_args = args.clone
    updated_args[:unknown_command] = 'unknown-command'

    tool, args = subject.determine_tool(args)

    tool.should == @help_tool
    args.should == updated_args
  end
end
