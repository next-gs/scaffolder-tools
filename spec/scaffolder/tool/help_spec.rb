require File.expand_path(File.join(File.dirname(__FILE__),'..','..','spec_helper'))

describe Scaffolder::Tool::Help do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  it "should return the description of the tool" do
    desc = "Help information for scaffolder commands"
    described_class.description.should == desc
  end

  USAGE = <<-MSG.gsub(/^ {6}/, '')
      usage: scaffolder [--version] COMMAND scaffold-file sequence-file
      [options]

      Commands:
    MSG

  before(:each) do
    @settings = Hash.new
    @settings.stubs(:rest).returns([])
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

    it "should contain each tool information" do
      tool_subclasses.each do |cls|
        subject.execute.should include(cls.description)
      end
    end

  end

  describe "execution with an invalid command arguments" do

    subject do
      @settings[:unknown_tool] = 'unknown_command'
      described_class.new(@settings)
    end

    it "should raise an error" do
      lambda{ subject.execute }.should(raise_error(ArgumentError,
        "Unknown command 'unknown_command'.\nSee 'scaffolder help'."))
    end

  end

  describe "execution with the name of a scaffolder tool command" do

    before(:each) do
      @tool = Class.new(described_class)
      described_class.superclass.const_set('Fake',@tool)

      @man_dir = File.join(%W|#{File.dirname(__FILE__)} .. .. .. man| )
      @fake_man = File.join(@man_dir,'scaffolder-fake.1.ronn')
    end

    after(:each) do
      described_class.superclass.send(:remove_const,'Fake')
    end

    subject do
      @settings.stubs(:rest).returns(['fake'])
      described_class.new(@settings)
    end

    it "should not raise an error" do
      Kernel.stubs(:system).
        with("ronn -m #{File.expand_path(@fake_man)}")
      lambda{ subject.execute }.should_not raise_error
    end

    it "should call ronn on the command line with the man file location" do
      Kernel.expects(:system).
        with("ronn -m #{File.expand_path(@fake_man)}")
      subject.execute
    end

  end

  describe "execution with the name of a unknown command" do

    subject do
      @settings.stubs(:rest).returns(['fake'])
      described_class.new(@settings)
    end

    it "should raise an error" do
      lambda{ subject.execute }.should(raise_error(ArgumentError,
        "Unknown command 'fake'.\nSee 'scaffolder help'."))
    end

  end
end
