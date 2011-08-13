require 'spec_helper'

describe Scaffolder::ToolIndex do

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

  describe "tool_exists? method" do

    it "should return false when no such tool exists" do
      subject.tool_exists?('unknown-tool').should be_false
    end

    it "should return true when the tool exists" do
      subject.tool_exists?(@tool_name).should be_true
    end

  end

  describe "get_tool method" do

    it "should return nil when no such tool exists" do
      subject.get_tool('unknown-tool').should be_nil
    end

    it "should return the tool class when the tool exists" do
      subject.get_tool(@tool_name).should == @tool_class
    end

  end

end
