require 'spec_helper'

describe Scaffolder::BinaryHelper do

  before(:each) do
    @help_tool = Scaffolder::Tool::Help

    @tool_class = Class.new(Scaffolder::Tool)
    @tool_name = 'type'
    Scaffolder::Tool.const_set(@tool_name.capitalize,@tool_class)

    @args = OpenStruct.new({ :rest => %W|#{@tool_name} arg1 arg2| })
  end

  after(:each) do
    Scaffolder::Tool.send(:remove_const,'Type')
  end

  subject do
    object = Object.new
    object.extend described_class
    object
  end

  describe "select_tool method" do

    it "should return corresponding tool subclass when requested by name" do
      subject[@tool_name].should == @tool_class
    end

    it "should return the help tool when passed an unknown name" do
      subject['unknown-tool'].should == @help_tool
    end

    it "should return the help tool when passed nil" do
      subject[nil].should == @help_tool
    end

  end

  it "should fetch the right tool class when requested" do
    tool, args = subject.determine_tool(@args)
    tool.should == @tool_class
    args.rest.should == @args.rest[-2..-1]
  end

  it "should fetch the help tool class when no arguments passed" do
    no_args = Hash.new
    no_args.expects(:rest).returns([])

    expected = no_args.clone
    expected[:empty_args] = true

    tool, args = subject.determine_tool(no_args)

    tool.should == @help_tool
    args.should == expected
  end

  it "should fetch the help tool class when an invalid argument is passed" do
    args = Hash.new
    args.expects(:rest).returns(['unknown-tool'])
    updated_args = args.clone
    updated_args[:unknown_tool] = 'unknown-tool'

    tool, args = subject.determine_tool(args)

    tool.should == @help_tool
    args.should == updated_args
  end
end
