require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ScaffoldValidate do

  it "should inherit from Scaffolder::Tool" do
    described_class.superclass.should == Scaffolder::Tool
  end

  describe "comparing inserts for overlaps" do

    before(:all) do
      @insert = stub(:position => 5..10)
    end

    it "should be false when inserts don't overlap" do
      no_overlap = stub(:position => 11..12)
      described_class.inserts_overlap?(@insert,no_overlap).should be_false
      described_class.inserts_overlap?(no_overlap,@insert).should be_false
    end

    it "should be true when inserts do overlap" do
      overlap = stub(:position => 10..11)
      described_class.inserts_overlap?(@insert,overlap).should be_true
      described_class.inserts_overlap?(overlap,@insert).should be_true
    end

  end

  describe "testing a sequence for overlapping inserts" do

    before(:all) do
      # Use integers for mocks because they can be easily sorted
      @a = 1; @b = 2
      @sequence = stub(:inserts => [@a,@b])
    end

    it "should return an empty array when sequence has no errors" do
      described_class.stubs(:inserts_overlap?).with(@a,@b).returns(false)
      described_class.stubs(:inserts_overlap?).with(@b,@a).returns(false)
      described_class.sequence_errors(@sequence).empty?.should be_true
    end

    it "should return inserts when sequence inserts overlap" do
      described_class.stubs(:inserts_overlap?).with(@a,@b).returns(true)
      described_class.stubs(:inserts_overlap?).with(@b,@a).returns(true)
      described_class.sequence_errors(@sequence).should == [[@a,@b]].sort
    end

  end

  describe "validating each entry in the scaffold" do

    before(:each) do
      @valid        = stub(:entry_type => :sequence)
      @invalid      = @valid.clone
      described_class.stubs(:sequence_errors).with(@valid).returns([])
      described_class.stubs(:sequence_errors).with(@invalid).returns([nil])
    end

    subject do
      ScaffoldValidate.new(mock_command_line_settings)
    end

    it "should return an empty array when scaffold is valid" do
      subject.expects(:scaffold).returns([@valid,@valid])
      subject.errors.should be_empty
    end

    it "should return invalid entries when scaffold is invalid" do
      subject.expects(:scaffold).returns([@invalid,@valid])
      subject.errors.should == [@invalid]
    end

    it "should ignore entries which are not sequences" do
      @non_sequence = stub(:entry_type => :other)
      subject.expects(:scaffold).returns([@invalid,@valid,@non_sequence])
      subject.errors.should == [@invalid]
    end

  end

  describe "scaffold validation with no overlapping inserts" do

    subject do
      validate = ScaffoldValidate.new(mock_command_line_settings)
      validate.stubs(:errors).returns([])
      validate
    end

    it "should not raise any errors" do
      lambda{ subject.execute }.should_not raise_error
    end

    it "should not return anything" do
      subject.execute.should == nil
    end

  end

  describe "returning errors using the errors method" do

    subject do
      ScaffoldValidate.new(mock_command_line_settings)
    end

    it "should return a yaml list of errors when scaffold is invalid" do
      sequence = stub(:source => :seq1)
      subject.stubs(:errors).returns([sequence])
      ScaffoldValidate.stubs(:sequence_errors).with(sequence).returns(
        [[stub(:open => 1,:close => 2)]])

      YAML.load(subject.execute).should == {:seq1 => [{
        :open => 1, :close => 2}]}
    end

  end

end
