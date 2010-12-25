require File.expand_path(File.join(File.dirname(__FILE__),'..','..','spec_helper'))

describe Scaffolder::Tool::Default do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  USAGE = <<-MSG
usage: scaffolder [--version] [--help] COMMAND scaffold-file sequence-file
[options]
  MSG

  before(:each) do
    @settings = Hash.new
    @settings.stubs(:rest).returns([])
  end

  describe "execution with no command and the help argument" do

    subject do
      @settings[:help] = true
      described_class.new(@settings)
    end

    it "should not raise an error" do
      lambda{ subject.execute }.should_not raise_error
    end

    it "should contain the usage information" do
      subject.execute.should include(USAGE)
    end

  end

  describe "execution with no command and the version argument" do

    subject do
      @settings[:version] = true
      described_class.new(@settings)
    end

    it "should not raise an error" do
      lambda{ subject.execute }.should_not raise_error
    end

    it "should return the version number" do
      version = File.read('VERSION').strip
      subject.execute.should == "scaffolder tool version " + version
    end

  end

  describe "execution with no command" do

    subject do
      described_class.new(@settings)
    end

    it "should not raise an error" do
      lambda{ subject.execute }.should_not raise_error
    end

    it "should contain the usage information" do
      subject.execute.should include(USAGE)
    end

  end

  describe "execution with an invalid command arguments" do

    subject do
      @settings[:unknown_command] = 'unknown_command'
      described_class.new(@settings)
    end

    it "should raise an error" do
      lambda{ subject.execute }.should(raise_error(ArgumentError,
        "Unknown command 'unknown_command'.\nSee 'scaffolder --help'."))
    end

  end

end
